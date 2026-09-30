package com.mentafinance.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.List;

/**
 * DTO MOJA inayotumika kwa roles ZOTE tatu - lakini fields fulani
 * zitabaki NULL kutegemea role (mf. STAFF atapata TU totalOutstanding,
 * fields nyingine zote null). Hii inafanya frontend iwe rahisi:
 * endpoint MOJA, muundo MMOJA, tofauti ni "nini kimejazwa".
 */
@Getter
@Builder
@AllArgsConstructor
public class DashboardResponse {
    private String role;

    private BigDecimal incomeThisMonth;      // null kwa STAFF
    private BigDecimal expensesThisMonth;    // null kwa STAFF
    private BigDecimal netProfit;            // null kwa STAFF

    private BigDecimal totalOutstanding;     // ZOTE tatu zinapata hii

    private List<TransactionResponse> recentTransactions;       // null kwa STAFF
    private List<ServicePerformanceResponse> performanceByService; // null kwa STAFF
}