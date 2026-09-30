package com.mentafinance.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;

/**
 * Hii ndiyo row moja ya jedwali "Client | Project | Price | Paid |
 * Outstanding" kwenye Client Detail Page uliyoieleza.
 */
@Getter
@Builder
@AllArgsConstructor
public class ProjectSummaryResponse {
    private Long projectId;
    private String projectName;
    private BigDecimal price;        // project_value
    private BigDecimal paid;         // SUM ya income za project hii
    private BigDecimal outstanding;  // price - paid
}