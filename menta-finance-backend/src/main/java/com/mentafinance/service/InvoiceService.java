package com.mentafinance.service;

import com.mentafinance.dto.request.InvoiceItemRequest;
import com.mentafinance.dto.request.InvoicePaymentRequest;
import com.mentafinance.dto.request.InvoiceRequest;
import com.mentafinance.dto.response.*;
import com.mentafinance.entity.*;
import com.mentafinance.entity.enums.IncomeSource;
import com.mentafinance.entity.enums.InvoiceStatus;
import com.mentafinance.exception.BusinessRuleException;
import com.mentafinance.exception.ResourceNotFoundException;
import com.mentafinance.repository.*;
import com.mentafinance.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.Year;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InvoiceService {

    private final InvoiceRepository invoiceRepository;
    private final InvoicePaymentRepository invoicePaymentRepository;
    private final IncomeRepository incomeRepository;
    private final ClientRepository clientRepository;
    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;

    private static final int MAX_INVOICE_NUMBER_RETRIES = 5;

    // =====================================================================
    // CREATE
    // =====================================================================
    @Transactional
    public InvoiceResponse create(InvoiceRequest request) {
        Client client = clientRepository.findById(request.getClientId())
                .orElseThrow(() -> new ResourceNotFoundException("Client haipo, ID: " + request.getClientId()));

        Project project = null;
        if (request.getProjectId() != null) {
            project = projectRepository.findById(request.getProjectId())
                    .orElseThrow(() -> new ResourceNotFoundException("Project haipo, ID: " + request.getProjectId()));
        }

        Invoice invoice = Invoice.builder()
                .client(client)
                .project(project)
                .issueDate(request.getIssueDate() != null ? request.getIssueDate() : LocalDate.now())
                .dueDate(request.getDueDate())
                .discount(request.getDiscount())
                .taxPercent(request.getTaxPercent())
                .notes(request.getNotes())
                .status(InvoiceStatus.DRAFT)
                .createdBy(userRepository.getReferenceById(SecurityUtils.getCurrentUserId()))
                .items(new ArrayList<>())
                .build();

        attachItemsAndCalculateTotals(invoice, request.getItems());

        invoice.setInvoiceNumber(generateNextInvoiceNumber());

        Invoice saved = saveInvoiceWithRetryOnNumberClash(invoice);

        if (request.getInitialAmountPaid() != null && request.getInitialAmountPaid().compareTo(BigDecimal.ZERO) > 0) {
            applyPayment(saved, request.getInitialAmountPaid(), request.getInitialPaymentMethod(), null, "Malipo ya awali wakati wa kuunda invoice");
        } else {
            saved.setStatus(InvoiceStatus.SENT);
            invoiceRepository.save(saved);
        }

        return toResponse(findOrThrow(saved.getId()));
    }

    // =====================================================================
    // RECORD PAYMENT (malipo ya baadaye - awamu ya pili, tatu, n.k.)
    // =====================================================================
    @Transactional
    public InvoiceResponse recordPayment(Long invoiceId, InvoicePaymentRequest request) {
        Invoice invoice = findOrThrow(invoiceId);

        if (invoice.getStatus() == InvoiceStatus.CANCELLED) {
            throw new BusinessRuleException("Huwezi kurekodi malipo kwenye invoice iliyofutwa (CANCELLED)");
        }

        applyPayment(invoice, request.getAmount(), request.getPaymentMethod(), request.getReferenceNo(), request.getNotes());

        return toResponse(findOrThrow(invoiceId));
    }

    private void applyPayment(Invoice invoice, BigDecimal amount, String method, String referenceNo, String notes) {

        if (invoice.getProject() == null) {
            throw new BusinessRuleException(
                "Invoice hii haina Project - haiwezi kurekodi malipo kwa sababu Income " +
                "LAZIMA iwe na Project. Tafadhali unganisha Invoice hii na Project kwanza."
            );
        }

        Long currentUserId = SecurityUtils.getCurrentUserId();

        InvoicePayment payment = InvoicePayment.builder()
                .invoice(invoice)
                .amount(amount)
                .paymentDate(LocalDate.now())
                .paymentMethod(method)
                .referenceNo(referenceNo)
                .notes(notes)
                .recordedBy(userRepository.getReferenceById(currentUserId))
                .build();
        InvoicePayment savedPayment = invoicePaymentRepository.save(payment);

        Income income = Income.builder()
                .project(invoice.getProject())
                .description("Malipo ya Invoice " + invoice.getInvoiceNumber())
                .amount(amount)
                .incomeDate(LocalDate.now())
                .paymentMethod(method)
                .sourceType(IncomeSource.INVOICE_PAYMENT)
                .invoicePayment(savedPayment)
                .recordedBy(userRepository.getReferenceById(currentUserId))
                .build();
        incomeRepository.save(income);

        BigDecimal newAmountPaid = invoicePaymentRepository.sumAmountByInvoiceId(invoice.getId());
        invoice.setAmountPaid(newAmountPaid);
        invoice.setStatus(computeStatus(invoice.getTotal(), newAmountPaid));

        invoiceRepository.save(invoice);
    }

    private InvoiceStatus computeStatus(BigDecimal total, BigDecimal amountPaid) {
        if (amountPaid.compareTo(BigDecimal.ZERO) <= 0) {
            return InvoiceStatus.SENT;
        } else if (amountPaid.compareTo(total) >= 0) {
            return InvoiceStatus.PAID;
        } else {
            return InvoiceStatus.PARTIAL;
        }
    }

    // =====================================================================
    // UPDATE
    // =====================================================================
    @Transactional
    public InvoiceResponse update(Long id, InvoiceRequest request) {
        Invoice invoice = findOrThrow(id);

        if (invoice.getStatus() == InvoiceStatus.PAID) {
            throw new BusinessRuleException("Huwezi kuhariri invoice ambayo tayari imelipwa kikamilifu (PAID)");
        }

        Client client = clientRepository.findById(request.getClientId())
                .orElseThrow(() -> new ResourceNotFoundException("Client haipo, ID: " + request.getClientId()));
        invoice.setClient(client);

        invoice.setProject(request.getProjectId() != null
                ? projectRepository.findById(request.getProjectId())
                    .orElseThrow(() -> new ResourceNotFoundException("Project haipo, ID: " + request.getProjectId()))
                : null);

        invoice.setDueDate(request.getDueDate());
        invoice.setDiscount(request.getDiscount());
        invoice.setTaxPercent(request.getTaxPercent());
        invoice.setNotes(request.getNotes());

        invoice.getItems().clear();
        attachItemsAndCalculateTotals(invoice, request.getItems());

        invoice.setStatus(computeStatus(invoice.getTotal(), invoice.getAmountPaid()));

        return toResponse(invoiceRepository.save(invoice));
    }

    @Transactional
    public void delete(Long id) {
        Invoice invoice = findOrThrow(id);
        if (invoice.getAmountPaid().compareTo(BigDecimal.ZERO) > 0) {
            throw new BusinessRuleException(
                "Huwezi kufuta invoice ambayo tayari ina malipo. Tumia CANCEL badala yake " +
                "kwa madhumuni ya kihasibu (audit trail)."
            );
        }
        invoiceRepository.delete(invoice);
    }

    // =====================================================================
    // READ
    // =====================================================================
    public InvoiceResponse getById(Long id) {
        return toResponse(findOrThrow(id));
    }

    public List<InvoiceResponse> getAll() {
        return invoiceRepository.findAll().stream().map(this::toResponse).toList();
    }

    public List<InvoiceResponse> getByClient(Long clientId) {
        return invoiceRepository.findByClientId(clientId).stream().map(this::toResponse).toList();
    }

    // =====================================================================
    // HELPERS
    // =====================================================================

    private void attachItemsAndCalculateTotals(Invoice invoice, List<InvoiceItemRequest> itemRequests) {
        BigDecimal subtotal = BigDecimal.ZERO;

        for (InvoiceItemRequest itemReq : itemRequests) {
            InvoiceItem item = InvoiceItem.builder()
                    .invoice(invoice)
                    .description(itemReq.getDescription())
                    .qty(itemReq.getQty())
                    .unitPrice(itemReq.getUnitPrice())
                    .build();
            invoice.getItems().add(item);

            subtotal = subtotal.add(itemReq.getQty().multiply(itemReq.getUnitPrice()));
        }

        BigDecimal discount = invoice.getDiscount() != null ? invoice.getDiscount() : BigDecimal.ZERO;
        BigDecimal taxPercent = invoice.getTaxPercent() != null ? invoice.getTaxPercent() : BigDecimal.ZERO;

        BigDecimal afterDiscount = subtotal.subtract(discount);
        BigDecimal taxAmount = afterDiscount.multiply(taxPercent)
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
        BigDecimal total = afterDiscount.add(taxAmount);

        invoice.setSubtotal(subtotal.setScale(2, RoundingMode.HALF_UP));
        invoice.setTaxAmount(taxAmount);
        invoice.setTotal(total.setScale(2, RoundingMode.HALF_UP));
    }

    private String generateNextInvoiceNumber() {
        int year = Year.now().getValue();
        String prefix = "INV-" + year + "-";
        long count = invoiceRepository.countByInvoiceNumberStartingWith(prefix);
        long next = count + 1;
        return prefix + String.format("%04d", next);
    }

    private Invoice saveInvoiceWithRetryOnNumberClash(Invoice invoice) {
        int attempts = 0;
        while (true) {
            try {
                return invoiceRepository.save(invoice);
            } catch (DataIntegrityViolationException ex) {
                attempts++;
                if (attempts >= MAX_INVOICE_NUMBER_RETRIES) {
                    throw new BusinessRuleException("Imeshindikana kutengeneza invoice number ya kipekee, jaribu tena");
                }
                invoice.setInvoiceNumber(generateNextInvoiceNumber());
            }
        }
    }

    private Invoice findOrThrow(Long id) {
        return invoiceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Invoice haipo, ID: " + id));
    }

    private InvoiceResponse toResponse(Invoice inv) {
        List<InvoiceItemResponse> items = inv.getItems().stream()
                .map(i -> InvoiceItemResponse.builder()
                        .id(i.getId())
                        .description(i.getDescription())
                        .qty(i.getQty())
                        .unitPrice(i.getUnitPrice())
                        // Kuhesabu WENYEWE badala ya kusoma i.getAmount() -
                        // ile ni GENERATED COLUMN ya PostgreSQL ambayo
                        // Hibernate haioni upya ndani ya transaction ile ile
                        // (Persistence Context inarudisha object ilivyokuwa
                        // kabla ya database kuihesabu). Kuhesabu wenyewe hapa
                        // kunatoa jibu sahihi kila wakati, bila kutegemea
                        // "kuisoma upya" kwa mzunguko wa pili wa database.
                        .amount(i.getQty().multiply(i.getUnitPrice()).setScale(2, RoundingMode.HALF_UP))
                        .build())
                .toList();

        List<InvoicePaymentResponse> payments = invoicePaymentRepository.findByInvoiceIdOrderByPaymentDateAsc(inv.getId()).stream()
                .map(p -> InvoicePaymentResponse.builder()
                        .id(p.getId()).amount(p.getAmount()).paymentDate(p.getPaymentDate())
                        .paymentMethod(p.getPaymentMethod()).referenceNo(p.getReferenceNo())
                        .build())
                .toList();

        return InvoiceResponse.builder()
                .id(inv.getId())
                .invoiceNumber(inv.getInvoiceNumber())
                .clientId(inv.getClient().getId())
                .clientName(inv.getClient().getName())
                .projectId(inv.getProject() != null ? inv.getProject().getId() : null)
                .projectName(inv.getProject() != null ? inv.getProject().getName() : null)
                .issueDate(inv.getIssueDate())
                .dueDate(inv.getDueDate())
                .subtotal(inv.getSubtotal())
                .discount(inv.getDiscount())
                .taxPercent(inv.getTaxPercent())
                .taxAmount(inv.getTaxAmount())
                .total(inv.getTotal())
                .amountPaid(inv.getAmountPaid())
                .balanceDue(inv.getTotal().subtract(inv.getAmountPaid()))
                .status(inv.getStatus())
                .notes(inv.getNotes())
                .items(items)
                .payments(payments)
                .build();
    }
}