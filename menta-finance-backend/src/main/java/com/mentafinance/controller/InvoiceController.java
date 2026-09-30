package com.mentafinance.controller;

import com.mentafinance.dto.request.InvoicePaymentRequest;
import com.mentafinance.dto.request.InvoiceRequest;
import com.mentafinance.dto.response.InvoiceResponse;
import com.mentafinance.service.InvoicePdfService;
import com.mentafinance.service.InvoiceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/invoices")
@RequiredArgsConstructor
public class InvoiceController {

    private final InvoiceService invoiceService;
    private final InvoicePdfService invoicePdfService;

    // Roles zote tatu zinaweza Create (kama ilivyokubaliwa - STAFF
    // "Create pekee"), ikiwa ni pamoja na malipo ya awali endapo yapo
    @PostMapping
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER','STAFF')")
    @ResponseStatus(HttpStatus.CREATED)
    public InvoiceResponse create(@Valid @RequestBody InvoiceRequest request) {
        return invoiceService.create(request);
    }

    // Malipo ya BAADAYE (awamu ya pili n.k.) - SUPERADMIN/MANAGER pekee,
    // kwa sababu hii ni "kusimamia" invoice iliyopo, si "kuunda" mpya
    @PostMapping("/{id}/payments")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    public InvoiceResponse recordPayment(@PathVariable Long id, @Valid @RequestBody InvoicePaymentRequest request) {
        return invoiceService.recordPayment(id, request);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    public InvoiceResponse update(@PathVariable Long id, @Valid @RequestBody InvoiceRequest request) {
        return invoiceService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        invoiceService.delete(id);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER','STAFF')")
    public List<InvoiceResponse> getAll() {
        return invoiceService.getAll();
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER','STAFF')")
    public InvoiceResponse getById(@PathVariable Long id) {
        return invoiceService.getById(id);
    }

    @GetMapping("/client/{clientId}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER','STAFF')")
    public List<InvoiceResponse> getByClient(@PathVariable Long clientId) {
        return invoiceService.getByClient(clientId);
    }

    /**
     * Kupakua invoice kama PDF halisi (kama muundo wa INV-2026-0003
     * uliotupa). Roles zote tatu zinaruhusiwa kuona/kupakua, kwa
     * sababu hata STAFF anaweza kuhitaji kutuma invoice kwa mteja.
     */
    @GetMapping("/{id}/pdf")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER','STAFF')")
    public ResponseEntity<ByteArrayResource> downloadPdf(@PathVariable Long id) {
        byte[] pdfBytes = invoicePdfService.generatePdf(id);
        ByteArrayResource resource = new ByteArrayResource(pdfBytes);

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header("Content-Disposition", "attachment; filename=invoice-" + id + ".pdf")
                .contentLength(pdfBytes.length)
                .body(resource);
    }
}