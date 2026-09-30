package com.mentafinance.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Builder
@AllArgsConstructor
public class InvoicePaymentResponse {
    private Long id;
    private BigDecimal amount;
    private LocalDate paymentDate;
    private String paymentMethod;
    private String referenceNo;
}