package com.mentafinance.dto.response;

import com.mentafinance.entity.enums.InvoiceStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Getter
@Builder
@AllArgsConstructor
public class InvoiceResponse {
    private Long id;
    private String invoiceNumber;
    private Long clientId;
    private String clientName;
    private Long projectId;
    private String projectName;
    private LocalDate issueDate;
    private LocalDate dueDate;
    private BigDecimal subtotal;
    private BigDecimal discount;
    private BigDecimal taxPercent;
    private BigDecimal taxAmount;
    private BigDecimal total;
    private BigDecimal amountPaid;
    private BigDecimal balanceDue;
    private InvoiceStatus status;
    private String notes;
    private List<InvoiceItemResponse> items;
    private List<InvoicePaymentResponse> payments;
}