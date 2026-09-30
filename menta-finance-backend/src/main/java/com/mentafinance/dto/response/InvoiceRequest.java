package com.mentafinance.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
public class InvoiceRequest {

    @NotNull(message = "Client inahitajika")
    private Long clientId;

    private Long projectId; // hiari (optional) - kama tulivyoona kwenye fomu yako

    private LocalDate issueDate;
    private LocalDate dueDate;

    @NotEmpty(message = "Invoice lazima iwe na item moja au zaidi")
    @Valid // MUHIMU: bila hii, validation ya ndani ya InvoiceItemRequest (mf. @NotBlank
           // kwenye description) HAITAFANYA KAZI - @Valid inasukuma validation "ndani"
           // ya kila kipengele cha list.
    private List<InvoiceItemRequest> items;

    @DecimalMin(value = "0.0", message = "Discount haiwezi kuwa hasi")
    private BigDecimal discount = BigDecimal.ZERO;

    @DecimalMin(value = "0.0", message = "Tax % haiwezi kuwa hasi")
    private BigDecimal taxPercent = BigDecimal.ZERO;

    private String notes;

    // Malipo ya awali (kama fomu yako ya awali ilivyoonyesha "Amount Paid")
    @DecimalMin(value = "0.0", message = "Amount Paid haiwezi kuwa hasi")
    private BigDecimal initialAmountPaid = BigDecimal.ZERO;

    private String initialPaymentMethod;
}