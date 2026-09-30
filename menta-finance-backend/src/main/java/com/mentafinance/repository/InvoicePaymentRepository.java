package com.mentafinance.repository;

import com.mentafinance.entity.InvoicePayment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;

public interface InvoicePaymentRepository extends JpaRepository<InvoicePayment, Long> {

    List<InvoicePayment> findByInvoiceIdOrderByPaymentDateAsc(Long invoiceId);

    /**
     * Hii ndiyo query itakayotumika kusasisha invoice.amountPaid
     * kila mara malipo mapya yanapoongezwa/kufutwa/kuhaririwa -
     * badala ya kuhesabu jumla kwa mkono kwenye Java loop.
     */
    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM InvoicePayment p WHERE p.invoice.id = :invoiceId")
    BigDecimal sumAmountByInvoiceId(@Param("invoiceId") Long invoiceId);
}
