package com.mentafinance.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;

@Getter
@Builder
@AllArgsConstructor
public class InvoiceItemResponse {
    private Long id;
    private String description;
    private BigDecimal qty;
    private BigDecimal unitPrice;
    private BigDecimal amount;
}