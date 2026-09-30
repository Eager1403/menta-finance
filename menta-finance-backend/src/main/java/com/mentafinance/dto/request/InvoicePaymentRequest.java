package com.mentafinance.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class InvoicePaymentRequest {

    @NotNull(message = "Amount inahitajika")
    @DecimalMin(value = "0.01", message = "Amount lazima iwe zaidi ya sifuri")
    private java.math.BigDecimal amount;

    private LocalDate paymentDate;
    private String paymentMethod;
    private String referenceNo;
    private String notes;
}