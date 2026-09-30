package com.mentafinance.entity;

import com.mentafinance.entity.enums.InvoiceStatus;
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
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "invoices")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Invoice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "invoice_number", nullable = false, unique = true, length = 30)
    private String invoiceNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id", nullable = false)
    private Client client;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id")
    private Project project;

    @Column(name = "issue_date", nullable = false)
    @Builder.Default
    private LocalDate issueDate = LocalDate.now();

    @Column(name = "due_date")
    private LocalDate dueDate;

    @Column(nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal subtotal = BigDecimal.ZERO;

    @Column(nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal discount = BigDecimal.ZERO;

    @Column(name = "tax_percent", nullable = false, precision = 5, scale = 2)
    @Builder.Default
    private BigDecimal taxPercent = BigDecimal.ZERO;

    @Column(name = "tax_amount", nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal taxAmount = BigDecimal.ZERO;

    @Column(nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal total = BigDecimal.ZERO;

    @Column(name = "amount_paid", nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal amountPaid = BigDecimal.ZERO;

    /**
     * balance_due ni GENERATED COLUMN kwenye PostgreSQL
     * (total - amount_paid, inahesabiwa na database yenyewe).
     * insertable/updatable = false kama InvoiceItem.amount hapo juu.
     */
    @Column(name = "balance_due", insertable = false, updatable = false, precision = 15, scale = 2)
    private BigDecimal balanceDue;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(columnDefinition = "invoice_status_enum", nullable = false)
    @Builder.Default
    private InvoiceStatus status = InvoiceStatus.DRAFT;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private User createdBy;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    /**
     * @OneToMany(mappedBy = "invoice") -> "Upande huu HAUMILIKI"
     *   uhusiano huu (mmiliki halisi ni InvoiceItem, kupitia
     *   @JoinColumn yake). "mappedBy" inaonyesha ni field gani
     *   upande wa InvoiceItem inayoelekeza kwenye Invoice hii.
     *
     * cascade = CascadeType.ALL -> ukifanya save/delete kwenye
     *   Invoice, operesheni hiyo hiyo "inashuka" kwenye items zake
     *   zote kiotomatiki. Mf. ukifuta Invoice, items zake zote
     *   zinafutwa pia (hazina maana bila invoice yao).
     *
     * orphanRemoval = true -> ukiondoa item kwenye hii list
     *   (invoice.getItems().remove(item)) na kisha ku-save Invoice,
     *   Hibernate ITAIFUTA hiyo item kwenye database kiotomatiki
     *   (badala ya kuiacha "yatima" bila invoice).
     *
     * @Builder.Default + new ArrayList<>() -> inazuia NullPointerException
     *   endapo mtu ataunda Invoice bila kutaja items wazi.
     */
    @OneToMany(mappedBy = "invoice", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @Builder.Default
    private List<InvoiceItem> items = new ArrayList<>();

    /**
     * Kwa payments, TUNATUMIA cascade = PERSIST TU (siyo ALL) na
     * orphanRemoval = false kimakusudi: hatutaki mtu "aondoe" malipo
     * kwenye list halafu ku-save Invoice na kuyafuta kimya kimya -
     * kufuta malipo ni operesheni nzito ya kihasibu inayopaswa kupitia
     * njia yake maalum (InvoiceService.deletePayment), siyo side-effect
     * ya ku-save Invoice.
     */
    @OneToMany(mappedBy = "invoice", cascade = CascadeType.PERSIST, fetch = FetchType.LAZY)
    @Builder.Default
    private List<InvoicePayment> payments = new ArrayList<>();
}
