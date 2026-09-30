package com.mentafinance.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Setter
public class ExpenseRequest {

    @NotNull(message = "Project inahitajika")
    private Long projectId;

    private String description;

    @NotNull(message = "Amount inahitajika")
    @DecimalMin(value = "0.01", message = "Amount lazima iwe zaidi ya sifuri")
    private BigDecimal amount;

    private LocalDate expenseDate;
    private String category;
}