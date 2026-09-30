package com.mentafinance.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
public class InvoiceItemRequest {

    @NotBlank(message = "Description ya item inahitajika")
    private String description;

    @NotNull
    @DecimalMin(value = "0.01", message = "Qty lazima iwe zaidi ya sifuri")
    private BigDecimal qty;

    @NotNull
    @DecimalMin(value = "0.0", inclusive = false, message = "Unit price lazima iwe zaidi ya sifuri")
    private BigDecimal unitPrice;
}