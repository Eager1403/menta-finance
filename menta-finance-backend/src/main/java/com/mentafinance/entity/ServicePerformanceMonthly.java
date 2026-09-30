package com.mentafinance.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Hili ni jedwali la "snapshot" - halijazwi na mtu moja kwa moja
 * (hakuna Create/Update/Delete endpoints za kawaida za CRUD).
 * Linajazwa na Scheduled Job (@Scheduled) mara moja kila mwezi,
 * kama tulivyokubaliana kwenye muundo wa Service Performance
 * (Hybrid: live kwa mwezi wa sasa, snapshot kwa miezi iliyopita).
 */
@Entity
@Table(name = "service_performance_monthly")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ServicePerformanceMonthly {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "service_id", nullable = false)
    private ServiceOffering service;

    /**
     * Tunahifadhi "siku ya kwanza ya mwezi" (mf. 2026-08-01)
     * kuwakilisha mwezi mzima wa Agosti 2026 - mbinu ya kawaida
     * ya kuhifadhi "mwezi" kama DATE kwenye SQL databases.
     */
    @Column(name = "year_month", nullable = false)
    private LocalDate yearMonth;

    @Column(name = "total_income", nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal totalIncome = BigDecimal.ZERO;

    @Column(name = "total_expense", nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal totalExpense = BigDecimal.ZERO;

    @Column(name = "net_profit", nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal netProfit = BigDecimal.ZERO;

    @Column(name = "project_count", nullable = false)
    @Builder.Default
    private Integer projectCount = 0;

    @Column(name = "client_count", nullable = false)
    @Builder.Default
    private Integer clientCount = 0;

    @Column(name = "avg_project_value", nullable = false, precision = 15, scale = 2)
    @Builder.Default
    private BigDecimal avgProjectValue = BigDecimal.ZERO;

    @Column(name = "generated_at", nullable = false)
    @Builder.Default
    private LocalDateTime generatedAt = LocalDateTime.now();
}
