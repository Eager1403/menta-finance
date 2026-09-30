package com.mentafinance.entity;

import com.mentafinance.entity.enums.IncomeSource;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "income")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Income {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * nullable = false kwenye ngazi ya Java pia (siyo tu database) -
     * kama ilivyokubaliwa: KILA income LAZIMA iwe na project (hata
     * ile ya "Company Overhead" kwa gharama za ndani).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    private Project project;

    @Column(length = 255)
    private String description;

    @Column(nullable = false, precision = 15, scale = 2)
    private BigDecimal amount;

    @Column(name = "income_date", nullable = false)
    @Builder.Default
    private LocalDate incomeDate = LocalDate.now();

    @Column(name = "payment_method", length = 50)
    private String paymentMethod;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "source_type", columnDefinition = "income_source_enum", nullable = false)
    @Builder.Default
    private IncomeSource sourceType = IncomeSource.MANUAL;

    /**
     * NULLABLE: itakuwa na thamani TU kama sourceType = INVOICE_PAYMENT.
     * Hii ndiyo "kiungo" kinachotuwezesha kujua Income hii ilitokana
     * na malipo gani hasa ya invoice gani.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "invoice_payment_id")
    private InvoicePayment invoicePayment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recorded_by")
    private User recordedBy;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
