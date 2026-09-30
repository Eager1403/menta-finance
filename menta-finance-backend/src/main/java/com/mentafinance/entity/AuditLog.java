package com.mentafinance.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;

/**
 * Hatutaitumia hii moja kwa moja sasa - itakuja kutumika kwenye
 * hatua za baadaye tutakapotekeleza "edit/delete window ya siku 7"
 * na tunataka kujua NANI alibadilisha NINI na LINI, kwa ajili ya
 * uwazi wa kihasibu (accountability).
 */
@Entity
@Table(name = "audit_log")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "entity_name", nullable = false, length = 50)
    private String entityName;

    @Column(name = "entity_id", nullable = false)
    private Long entityId;

    @Column(nullable = false, length = 20)
    private String action; // CREATE / UPDATE / DELETE

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "performed_by")
    private User performedBy;

    /**
     * JSONB kwenye PostgreSQL -> tunahifadhi kama String ya JSON
     * kwa sasa (rahisi zaidi); tukihitaji querying ya ndani ya JSON
     * baadaye, tutatumia @JdbcTypeCode(SqlTypes.JSON) badala yake.
     */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "old_value", columnDefinition = "jsonb")
    private String oldValue;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "new_value", columnDefinition = "jsonb")
    private String newValue;

    @CreationTimestamp
    @Column(name = "performed_at", nullable = false, updatable = false)
    private LocalDateTime performedAt;
}
