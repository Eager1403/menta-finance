package com.mentafinance.repository;

import com.mentafinance.entity.Invoice;
import com.mentafinance.entity.enums.InvoiceStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface InvoiceRepository extends JpaRepository<Invoice, Long> {

    Optional<Invoice> findByInvoiceNumber(String invoiceNumber);

    List<Invoice> findByClientId(Long clientId);

    List<Invoice> findByProjectId(Long projectId);

    List<Invoice> findByStatus(InvoiceStatus status);

    /**
     * Kwa kutengeneza invoice number ya mfumo "INV-2026-0003":
     * tunahesabu ni invoice ngapi tayari zina prefix ya mwaka huu
     * (mf. "INV-2026-"), kisha Service layer itaongeza 1 na
     * kuweka namba zenye "0" mbele (padding) - hii itafanyika
     * kwenye InvoiceService, tutakapofika huko.
     */
    long countByInvoiceNumberStartingWith(String prefix);
}
