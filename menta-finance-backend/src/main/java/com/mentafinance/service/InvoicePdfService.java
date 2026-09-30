package com.mentafinance.service;

import com.lowagie.text.*;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPCellEvent;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.mentafinance.dto.response.InvoiceItemResponse;
import com.mentafinance.dto.response.InvoiceResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.Locale;

/**
 * Inatengeneza PDF ya invoice kwa muundo wa INV-2026-0003 (sampuli ya
 * Menta Studio): logo juu kushoto, "INVOICE" kijani juu kulia, mstari
 * mnene wa kijani, boksi za BILL TO / PROJECT zenye kona za mviringo,
 * jedwali la items, muhtasari wa fedha (TOTAL kwenye boksi jeusi,
 * Balance Due kwenye boksi la kijani), Payment Terms yenye mstari wa
 * kijani upande wa kushoto, na footer.
 *
 * MUHIMU kuhusu imports: tunaingiza `java.awt.Color` PEKEE (siyo
 * `java.awt.*`) ili isigongane na `com.lowagie.text.Font` / `Image`.
 *
 * LOGO: faili ya logo iko kwenye
 *   src/main/resources/images/menta-logo.png
 * Ikikosekana, PDF bado itatengenezwa (itatumia jina "Menta Studio" kwa
 * maandishi badala ya picha).
 */
@Service
@RequiredArgsConstructor
public class InvoicePdfService {

    private final InvoiceService invoiceService;

    // ---- Rangi (zinalingana na sampuli ya Menta Studio) ----
    private static final Color GREEN = new Color(22, 163, 74);      // kijani cha brand
    private static final Color NAVY = new Color(15, 23, 42);        // maandishi makuu / boksi jeusi
    private static final Color SLATE = new Color(71, 85, 105);      // maandishi ya pili
    private static final Color GRAY = new Color(100, 116, 139);     // labels ndogo
    private static final Color BORDER = new Color(226, 232, 240);   // mistari myepesi

    private static final String LOGO_PATH = "images/menta-logo.png";

    // Cache ya bytes za logo (inasomwa mara moja tu)
    private volatile byte[] logoBytes;
    private volatile boolean logoLoaded = false;

    public byte[] generatePdf(Long invoiceId) {
        InvoiceResponse invoice = invoiceService.getById(invoiceId);

        try {
            Document document = new Document(PageSize.A4, 42, 42, 36, 36);
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            PdfWriter.getInstance(document, out);
            document.open();

            addHeader(document, invoice);
            addDivider(document, GREEN, 3f, 10f, 14f);
            addBillToAndProjectBoxes(document, invoice);
            addItemsTable(document, invoice);
            addTotalsSection(document, invoice);
            addPaymentTerms(document, invoice);
            addFooter(document);

            document.close();
            return out.toByteArray();

        } catch (DocumentException e) {
            throw new RuntimeException("Imeshindikana kutengeneza PDF ya invoice", e);
        }
    }

    // =====================================================================
    //  HEADER: logo (kushoto)  |  INVOICE + namba + tarehe (kulia)
    // =====================================================================
    private void addHeader(Document document, InvoiceResponse invoice) throws DocumentException {
        PdfPTable header = new PdfPTable(2);
        header.setWidthPercentage(100);
        header.setWidths(new float[]{1.15f, 1f});

        // Kushoto: logo
        PdfPCell left = new PdfPCell();
        left.setBorder(Rectangle.NO_BORDER);
        Image logo = loadLogo();
        if (logo != null) {
            logo.scaleToFit(185f, 62f);
            left.addElement(logo);
        } else {
            left.addElement(new Paragraph("Menta Studio", new Font(Font.HELVETICA, 24, Font.BOLD, NAVY)));
        }
        header.addCell(left);

        // Kulia: INVOICE (kijani), namba, Issued, Due
        Font titleFont = new Font(Font.HELVETICA, 30, Font.BOLD, GREEN);
        Font numberFont = new Font(Font.HELVETICA, 11, Font.BOLD, SLATE);
        Font metaFont = new Font(Font.HELVETICA, 10, Font.NORMAL, GRAY);

        PdfPCell right = new PdfPCell();
        right.setBorder(Rectangle.NO_BORDER);

        Paragraph title = new Paragraph("INVOICE", titleFont);
        title.setAlignment(Element.ALIGN_RIGHT);
        right.addElement(title);

        Paragraph number = new Paragraph(String.valueOf(invoice.getInvoiceNumber()), numberFont);
        number.setAlignment(Element.ALIGN_RIGHT);
        right.addElement(number);

        Paragraph issued = new Paragraph("Issued: " + invoice.getIssueDate(), metaFont);
        issued.setAlignment(Element.ALIGN_RIGHT);
        right.addElement(issued);

        if (invoice.getDueDate() != null) {
            Paragraph due = new Paragraph("Due: " + invoice.getDueDate(), metaFont);
            due.setAlignment(Element.ALIGN_RIGHT);
            right.addElement(due);
        }
        header.addCell(right);

        document.add(header);
    }

    // =====================================================================
    //  BILL TO / PROJECT (boksi mbili zenye kona za mviringo)
    // =====================================================================
    private void addBillToAndProjectBoxes(Document document, InvoiceResponse invoice) throws DocumentException {
        PdfPTable table = new PdfPTable(3);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{1f, 0.07f, 1f});
        table.setSpacingBefore(4);

        Font labelFont = new Font(Font.HELVETICA, 9, Font.NORMAL, SLATE);
        Font valueFont = new Font(Font.HELVETICA, 13, Font.BOLD, NAVY);

        String client = invoice.getClientName() != null ? invoice.getClientName().toUpperCase() : "-";
        String project = invoice.getProjectName() != null ? invoice.getProjectName().toUpperCase() : "-";

        table.addCell(buildInfoBox("BILL TO", client, labelFont, valueFont));

        PdfPCell gap = new PdfPCell(new Phrase(""));
        gap.setBorder(Rectangle.NO_BORDER);
        table.addCell(gap);

        table.addCell(buildInfoBox("PROJECT", project, labelFont, valueFont));

        document.add(table);
    }

    private PdfPCell buildInfoBox(String label, String value, Font labelFont, Font valueFont) {
        PdfPCell cell = new PdfPCell();
        cell.setBorder(Rectangle.NO_BORDER);
        cell.setPadding(12);
        cell.setPaddingBottom(14);

        cell.addElement(new Paragraph(label, labelFont));
        Paragraph v = new Paragraph(value, valueFont);
        v.setSpacingBefore(5);
        cell.addElement(v);

        cell.setCellEvent(new RoundedBoxEvent(Color.WHITE, BORDER, 9f, 0.9f));
        return cell;
    }

    // =====================================================================
    //  JEDWALI LA ITEMS
    // =====================================================================
    private void addItemsTable(Document document, InvoiceResponse invoice) throws DocumentException {
        PdfPTable table = new PdfPTable(4);
        table.setWidthPercentage(100);
        table.setSpacingBefore(24);
        table.setWidths(new float[]{3.3f, 0.9f, 2.8f, 2.9f});

        Font headerFont = new Font(Font.HELVETICA, 8.5f, Font.BOLD, GRAY);
        Font cellFont = new Font(Font.HELVETICA, 11.5f, Font.NORMAL, NAVY);

        addHeaderCell(table, "DESCRIPTION", headerFont, Element.ALIGN_LEFT);
        addHeaderCell(table, "QTY", headerFont, Element.ALIGN_RIGHT);
        addHeaderCell(table, "UNIT PRICE", headerFont, Element.ALIGN_RIGHT);
        addHeaderCell(table, "AMOUNT", headerFont, Element.ALIGN_RIGHT);

        if (invoice.getItems() != null) {
            for (InvoiceItemResponse item : invoice.getItems()) {
                addBodyCell(table, item.getDescription(), cellFont, Element.ALIGN_LEFT);
                addBodyCell(table, item.getQty().stripTrailingZeros().toPlainString(), cellFont, Element.ALIGN_RIGHT);
                addBodyCell(table, "TZS " + formatMoney(item.getUnitPrice()), cellFont, Element.ALIGN_RIGHT);
                addBodyCell(table, "TZS " + formatMoney(item.getAmount()), cellFont, Element.ALIGN_RIGHT);
            }
        }

        document.add(table);
    }

    private void addHeaderCell(PdfPTable table, String text, Font font, int alignment) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBorder(Rectangle.BOTTOM);
        cell.setBorderColor(BORDER);
        cell.setBorderWidth(1f);
        cell.setPaddingBottom(9);
        cell.setPaddingLeft(6);
        cell.setPaddingRight(6);
        cell.setHorizontalAlignment(alignment);
        table.addCell(cell);
    }

    private void addBodyCell(PdfPTable table, String text, Font font, int alignment) {
        PdfPCell cell = new PdfPCell(new Phrase(text == null ? "" : text, font));
        cell.setBorder(Rectangle.BOTTOM);
        cell.setBorderColor(BORDER);
        cell.setBorderWidth(0.8f);
        cell.setPadding(9);
        cell.setHorizontalAlignment(alignment);
        table.addCell(cell);
    }

    // =====================================================================
    //  MUHTASARI WA FEDHA (upande wa kulia)
    // =====================================================================
    private void addTotalsSection(Document document, InvoiceResponse invoice) throws DocumentException {
        PdfPTable wrapper = new PdfPTable(2);
        wrapper.setWidthPercentage(100);
        wrapper.setSpacingBefore(18);
        wrapper.setWidths(new float[]{1.05f, 1f});

        PdfPCell emptyCell = new PdfPCell(new Phrase(""));
        emptyCell.setBorder(Rectangle.NO_BORDER);
        wrapper.addCell(emptyCell);

        PdfPTable totals = new PdfPTable(2);
        totals.setWidthPercentage(100);
        totals.setWidths(new float[]{1f, 1.2f});

        Font labelFont = new Font(Font.HELVETICA, 11.5f, Font.NORMAL, NAVY);
        Font valueFont = new Font(Font.HELVETICA, 11.5f, Font.BOLD, NAVY);
        Font whiteLabel = new Font(Font.HELVETICA, 13, Font.BOLD, Color.WHITE);
        Font whiteValue = new Font(Font.HELVETICA, 13, Font.BOLD, Color.WHITE);

        addTotalRow(totals, "Subtotal", "TZS " + formatMoney(invoice.getSubtotal()), labelFont, valueFont);
        addTotalRow(totals, "Discount", "TZS " + formatMoney(invoice.getDiscount()), labelFont, valueFont);
        addTotalRow(totals, "Tax / VAT", "TZS " + formatMoney(invoice.getTaxAmount()), labelFont, valueFont);
        addSpacerRow(totals, 4f);
        addHighlightRow(totals, "TOTAL", "TZS " + formatMoney(invoice.getTotal()), NAVY, whiteLabel, whiteValue);
        addSpacerRow(totals, 6f);
        addTotalRow(totals, "Amount Paid", "TZS " + formatMoney(invoice.getAmountPaid()), labelFont, valueFont);
        addSpacerRow(totals, 4f);
        addHighlightRow(totals, "Balance Due", "TZS " + formatMoney(invoice.getBalanceDue()), GREEN, whiteLabel, whiteValue);

        PdfPCell totalsCell = new PdfPCell(totals);
        totalsCell.setBorder(Rectangle.NO_BORDER);
        totalsCell.setPadding(0);
        wrapper.addCell(totalsCell);

        document.add(wrapper);
    }

    private void addTotalRow(PdfPTable table, String label, String value, Font labelFont, Font valueFont) {
        PdfPCell labelCell = new PdfPCell(new Phrase(label, labelFont));
        labelCell.setBorder(Rectangle.NO_BORDER);
        labelCell.setPaddingTop(4);
        labelCell.setPaddingBottom(4);
        labelCell.setPaddingLeft(2);
        table.addCell(labelCell);

        PdfPCell valueCell = new PdfPCell(new Phrase(value, valueFont));
        valueCell.setBorder(Rectangle.NO_BORDER);
        valueCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
        valueCell.setPaddingTop(4);
        valueCell.setPaddingBottom(4);
        valueCell.setPaddingRight(2);
        table.addCell(valueCell);
    }

    /** Mstari wa TOTAL / Balance Due: boksi lenye rangi imara na maandishi meupe. */
    private void addHighlightRow(PdfPTable table, String label, String value, Color fill,
                                 Font labelFont, Font valueFont) throws DocumentException {
        PdfPTable inner = new PdfPTable(2);
        inner.setWidthPercentage(100);
        inner.setWidths(new float[]{1f, 1.3f});

        PdfPCell l = new PdfPCell(new Phrase(label, labelFont));
        l.setBorder(Rectangle.NO_BORDER);
        l.setPaddingTop(10);
        l.setPaddingBottom(10);
        l.setPaddingLeft(12);
        inner.addCell(l);

        PdfPCell v = new PdfPCell(new Phrase(value, valueFont));
        v.setBorder(Rectangle.NO_BORDER);
        v.setHorizontalAlignment(Element.ALIGN_RIGHT);
        v.setPaddingTop(10);
        v.setPaddingBottom(10);
        v.setPaddingRight(12);
        inner.addCell(v);

        PdfPCell wrapper = new PdfPCell(inner);
        wrapper.setColspan(2);
        wrapper.setBorder(Rectangle.NO_BORDER);
        wrapper.setPadding(0);
        wrapper.setCellEvent(new RoundedBoxEvent(fill, null, 9f, 0f));
        table.addCell(wrapper);
    }

    private void addSpacerRow(PdfPTable table, float height) {
        PdfPCell spacer = new PdfPCell(new Phrase(""));
        spacer.setColspan(2);
        spacer.setBorder(Rectangle.NO_BORDER);
        spacer.setFixedHeight(height);
        table.addCell(spacer);
    }

    // =====================================================================
    //  PAYMENT TERMS (mstari wa kijani upande wa kushoto) + FOOTER
    // =====================================================================
    private void addPaymentTerms(Document document, InvoiceResponse invoice) throws DocumentException {
        if (invoice.getNotes() == null || invoice.getNotes().isBlank()) {
            return;
        }

        PdfPTable box = new PdfPTable(1);
        box.setWidthPercentage(100);
        box.setSpacingBefore(28);

        PdfPCell cell = new PdfPCell();
        cell.setBorder(Rectangle.LEFT);
        cell.setBorderColorLeft(GREEN);
        cell.setBorderWidthLeft(3.5f);
        cell.setPaddingLeft(14);
        cell.setPaddingTop(8);
        cell.setPaddingBottom(10);
        cell.setPaddingRight(8);

        cell.addElement(new Paragraph("Payment Terms / Notes", new Font(Font.HELVETICA, 12, Font.BOLD, NAVY)));
        cell.addElement(new Paragraph(invoice.getNotes(), new Font(Font.HELVETICA, 11, Font.NORMAL, NAVY)));

        box.addCell(cell);
        document.add(box);
    }

    private void addFooter(Document document) throws DocumentException {
        addDivider(document, NAVY, 1.2f, 36f, 10f);

        Paragraph thankYou = new Paragraph("Thank you for your business!",
                new Font(Font.HELVETICA, 10, Font.BOLD, GREEN));
        thankYou.setAlignment(Element.ALIGN_CENTER);
        document.add(thankYou);

        // \u2022 = "•" (bullet) - Helvetica (Cp1252) inaisaidia
        Paragraph footer = new Paragraph("Menta Studio \u2022 Menta Finance",
                new Font(Font.HELVETICA, 9, Font.NORMAL, SLATE));
        footer.setAlignment(Element.ALIGN_CENTER);
        document.add(footer);
    }

    // =====================================================================
    //  VIFAA VYA MSAADA
    // =====================================================================
    private void addDivider(Document document, Color color, float height,
                            float spacingBefore, float spacingAfter) throws DocumentException {
        PdfPTable divider = new PdfPTable(1);
        divider.setWidthPercentage(100);
        divider.setSpacingBefore(spacingBefore);
        divider.setSpacingAfter(spacingAfter);

        PdfPCell cell = new PdfPCell();
        cell.setFixedHeight(height);
        cell.setBackgroundColor(color);
        cell.setBorder(Rectangle.NO_BORDER);
        divider.addCell(cell);

        document.add(divider);
    }

    private Image loadLogo() {
        byte[] bytes = getLogoBytes();
        if (bytes == null) {
            return null;
        }
        try {
            return Image.getInstance(bytes);
        } catch (Exception e) {
            return null;
        }
    }

    private byte[] getLogoBytes() {
        if (!logoLoaded) {
            synchronized (this) {
                if (!logoLoaded) {
                    try (InputStream in = new ClassPathResource(LOGO_PATH).getInputStream()) {
                        logoBytes = in.readAllBytes();
                    } catch (Exception e) {
                        logoBytes = null; // logo haipo - tutatumia maandishi
                    }
                    logoLoaded = true;
                }
            }
        }
        return logoBytes;
    }

    /** NumberFormat si thread-safe, kwa hiyo tunaunda mpya kila mara. */
    private String formatMoney(BigDecimal amount) {
        if (amount == null) {
            return "0";
        }
        NumberFormat nf = NumberFormat.getNumberInstance(Locale.US);
        nf.setMaximumFractionDigits(2);
        return nf.format(amount);
    }

    /**
     * Inachora boksi lenye kona za mviringo nyuma ya cell (rangi ya ndani
     * na/au mstari wa nje). Inatumika kwa BILL TO/PROJECT, TOTAL na
     * Balance Due.
     */
    private static class RoundedBoxEvent implements PdfPCellEvent {
        private final Color fill;
        private final Color stroke;
        private final float radius;
        private final float lineWidth;

        RoundedBoxEvent(Color fill, Color stroke, float radius, float lineWidth) {
            this.fill = fill;
            this.stroke = stroke;
            this.radius = radius;
            this.lineWidth = lineWidth;
        }

        @Override
        public void cellLayout(PdfPCell cell, Rectangle position, PdfContentByte[] canvases) {
            PdfContentByte canvas = canvases[PdfPTable.BACKGROUNDCANVAS];
            canvas.saveState();

            float inset = lineWidth / 2f;
            canvas.roundRectangle(
                    position.getLeft() + inset,
                    position.getBottom() + inset,
                    position.getWidth() - lineWidth,
                    position.getHeight() - lineWidth,
                    radius);

            if (fill != null) {
                canvas.setColorFill(fill);
            }
            if (stroke != null) {
                canvas.setColorStroke(stroke);
                canvas.setLineWidth(lineWidth);
            }

            if (fill != null && stroke != null) {
                canvas.fillStroke();
            } else if (fill != null) {
                canvas.fill();
            } else if (stroke != null) {
                canvas.stroke();
            } else {
                canvas.newPath();
            }
            canvas.restoreState();
        }
    }
}