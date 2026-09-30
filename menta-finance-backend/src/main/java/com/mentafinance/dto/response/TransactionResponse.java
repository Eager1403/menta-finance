package com.mentafinance.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Row moja ya "Transactions za hivi karibuni" - inaweza kuwa
 * Income AU Expense, ndiyo maana ina field ya "type".
 */
@Getter
@Builder
@AllArgsConstructor
public class TransactionResponse {
    private String type; // "INCOME" au "EXPENSE"
    private LocalDate date;
    private String description;
    private BigDecimal amount;
}