package com.mentafinance.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Builder
@AllArgsConstructor
public class ClientDetailResponse {
    private Long clientId;
    private String clientName;
    private List<ProjectSummaryResponse> projects;
    private BigDecimal totalOutstanding; // jumla ya outstanding za projects zote
}