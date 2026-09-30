package com.mentafinance.repository;

import com.mentafinance.entity.InvoiceItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/**
 * Kumbuka: mara nyingi tutafikia InvoiceItems kupitia
 * invoice.getItems() moja kwa moja (kwa sababu ya @OneToMany
 * tuliyoiweka kwenye Invoice.java). Repository hii itatumika
 * zaidi kwa queries za moja kwa moja, si kila wakati.
 */
public interface InvoiceItemRepository extends JpaRepository<InvoiceItem, Long> {

    List<InvoiceItem> findByInvoiceId(Long invoiceId);
}
