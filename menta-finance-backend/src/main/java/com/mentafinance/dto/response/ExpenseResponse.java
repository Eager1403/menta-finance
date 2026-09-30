package com.mentafinance.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Builder
@AllArgsConstructor
public class ExpenseResponse {
    private Long id;
    private Long projectId;
    private String projectName;
    private String description;
    private BigDecimal amount;
    private LocalDate expenseDate;
    private String category;
}