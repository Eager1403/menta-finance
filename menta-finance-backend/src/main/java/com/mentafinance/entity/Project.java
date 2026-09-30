package com.mentafinance.entity;

import com.mentafinance.entity.enums.ProjectStatus;
import com.mentafinance.entity.enums.ProjectType;
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
@Table(name = "projects")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Project {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 200)
    private String name;

    /**
     * NULLABLE kimakusudi: project za PROJECT_TYPE=INTERNAL (mf.
     * "Company Overhead") hazina client. Uthibitisho halisi wa
     * "CLIENT type LAZIMA iwe na client_id" unafanywa na
     * CHECK constraint kwenye database (chk_client_required) NA
     * pia tutauthibitisha tena kwenye Service layer (defense in depth -
     * kutegemea DB pekee siyo salama, mtu anaweza kupitisha validation
     * ya Java lakini database bado itamzuia; na kinyume chake, kutegemea
     * Java pekee siyo salama endapo kuna direct DB access baadaye).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "client_id")
    private Client client;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "service_id")
    private ServiceOffering service;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "project_type", columnDefinition = "project_type_enum", nullable = false)
    @Builder.Default
    private ProjectType projectType = ProjectType.CLIENT;

    /**
     * precision=15, scale=2 -> namba yenye hadi tarakimu 15 jumla,
     * na tarakimu 2 baada ya nukta (mf. 999999999999.99) - inaendana
     * na NUMERIC(15,2) kwenye PostgreSQL.
     */
    @Column(name = "project_value", nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal projectValue = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(columnDefinition = "project_status_enum", nullable = false)
    @Builder.Default
    private ProjectStatus status = ProjectStatus.ONGOING;

    @Column(name = "start_date")
    private LocalDate startDate;

    @Column(name = "end_date")
    private LocalDate endDate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private User createdBy;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
