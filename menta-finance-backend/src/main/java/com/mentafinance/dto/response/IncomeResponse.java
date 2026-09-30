package com.mentafinance.dto.response;

import com.mentafinance.entity.enums.IncomeSource;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Builder
@AllArgsConstructor
public class IncomeResponse {
    private Long id;
    private Long projectId;
    private String projectName;
    private String description;
    private BigDecimal amount;
    private LocalDate incomeDate;
    private String paymentMethod;
    private IncomeSource sourceType;
}