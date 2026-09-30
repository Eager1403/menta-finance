package com.mentafinance.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import java.math.BigDecimal;

@Entity
@Table(name = "invoice_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InvoiceItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * @ToString.Exclude -> Bila hii, ukijaribu ku-print InvoiceItem
     *   (mf. kwenye logs), itajaribu pia ku-print Invoice yake, ambayo
     *   nayo ina list ya InvoiceItems - hii inaweza kusababisha
     *   "infinite loop" (StackOverflowError) kwa sababu ya mzunguko:
     *   Invoice -> items -> Invoice -> items -> ...
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "invoice_id", nullable = false)
    @ToString.Exclude
    private Invoice invoice;

    @Column(nullable = false, length = 255)
    private String description;

    @Column(nullable = false, precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal qty = BigDecimal.ONE;

    @Column(name = "unit_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal unitPrice;

    /**
     * insertable = false, updatable = false -> hii column PostgreSQL
     * yenyewe inaihesabu (GENERATED ALWAYS AS qty*unit_price STORED).
     * Tukijaribu ku-INSERT thamani wenyewe, PostgreSQL itatupa error.
     * Kwa hiyo tunamwambia Hibernate "SOMA hii tu, USIANDIKE kamwe".
     */
    @Column(insertable = false, updatable = false, precision = 15, scale = 2)
    private BigDecimal amount;
}
