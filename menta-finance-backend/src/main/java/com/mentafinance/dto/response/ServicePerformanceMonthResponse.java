package com.mentafinance.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Builder
@AllArgsConstructor
public class ServicePerformanceMonthResponse {
    private Long serviceId;
    private String serviceName;
    private LocalDate yearMonth;
    private BigDecimal totalIncome;
    private BigDecimal totalExpense;
    private BigDecimal netProfit;
    private Integer projectCount;
    private Integer clientCount;
    private BigDecimal avgProjectValue;
    private Boolean isLive; // true = mwezi wa sasa (bado haujafungwa), false = snapshot
}