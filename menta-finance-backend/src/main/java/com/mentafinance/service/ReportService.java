package com.mentafinance.service;

import com.mentafinance.dto.response.ServicePerformanceMonthResponse;
import com.mentafinance.entity.ServiceOffering;
import com.mentafinance.entity.ServicePerformanceMonthly;
import com.mentafinance.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;

@Service
@RequiredArgsConstructor
public class ReportService {

    private final ServiceOfferingRepository serviceOfferingRepository;
    private final IncomeRepository incomeRepository;
    private final ExpenseRepository expenseRepository;
    private final ProjectRepository projectRepository;
    private final ServicePerformanceMonthlyRepository performanceRepository;
    private final ServicePerformanceSchedulerService schedulerService;

    /**
     * Inarudisha historia ya "monthsBack" miezi (ikiwa ni pamoja na
     * mwezi wa sasa, uliohesabiwa LIVE, siyo kutoka snapshot table).
     */
    public List<ServicePerformanceMonthResponse> getServicePerformanceHistory(int monthsBack) {
        List<ServicePerformanceMonthResponse> result = new ArrayList<>();

        YearMonth currentMonth = YearMonth.now();
        YearMonth earliestMonth = currentMonth.minusMonths(monthsBack - 1);

        // (1) Miezi ILIYOPITA (siyo mwezi wa sasa) - kutoka SNAPSHOT table
        LocalDate historyStart = earliestMonth.atDay(1);
        LocalDate historyEnd = currentMonth.minusMonths(1).atEndOfMonth();

        if (!historyStart.isAfter(historyEnd)) {
            List<ServicePerformanceMonthly> snapshots =
                    performanceRepository.findByYearMonthBetweenOrderByYearMonthAsc(historyStart, historyEnd);

            for (ServicePerformanceMonthly s : snapshots) {
                result.add(ServicePerformanceMonthResponse.builder()
                        .serviceId(s.getService().getId())
                        .serviceName(s.getService().getName())
                        .yearMonth(s.getYearMonth())
                        .totalIncome(s.getTotalIncome())
                        .totalExpense(s.getTotalExpense())
                        .netProfit(s.getNetProfit())
                        .projectCount(s.getProjectCount())
                        .clientCount(s.getClientCount())
                        .avgProjectValue(s.getAvgProjectValue())
                        .isLive(false)
                        .build());
            }
        }

        // (2) MWEZI WA SASA - LIVE (siyo kutoka snapshot, kwa sababu
        // mwezi huu bado "haujafungwa")
        result.addAll(computeLiveForMonth(currentMonth));

        return result;
    }

    private List<ServicePerformanceMonthResponse> computeLiveForMonth(YearMonth yearMonth) {
        LocalDate start = yearMonth.atDay(1);
        LocalDate end = LocalDate.now().isAfter(yearMonth.atEndOfMonth()) ? yearMonth.atEndOfMonth() : LocalDate.now();

        Map<Long, BigDecimal> incomeByService = toMap(incomeRepository.sumAmountGroupedByServiceForDateRange(start, end));
        Map<Long, BigDecimal> expenseByService = toMap(expenseRepository.sumAmountGroupedByServiceForDateRange(start, end));

        List<ServicePerformanceMonthResponse> list = new ArrayList<>();
        for (ServiceOffering service : serviceOfferingRepository.findAll()) {
            BigDecimal income = incomeByService.getOrDefault(service.getId(), BigDecimal.ZERO);
            BigDecimal expense = expenseByService.getOrDefault(service.getId(), BigDecimal.ZERO);

            list.add(ServicePerformanceMonthResponse.builder()
                    .serviceId(service.getId())
                    .serviceName(service.getName())
                    .yearMonth(start)
                    .totalIncome(income)
                    .totalExpense(expense)
                    .netProfit(income.subtract(expense))
                    .projectCount((int) projectRepository.countByServiceId(service.getId()))
                    .clientCount((int) projectRepository.countDistinctClientsByServiceId(service.getId()))
                    .avgProjectValue(projectRepository.avgProjectValueByServiceId(service.getId()))
                    .isLive(true)
                    .build());
        }
        return list;
    }

    /**
     * Kwa SuperAdmin: "backfill" au "regenerate" snapshot ya mwezi
     * maalum kwa mkono (mf. endapo cron ilishindwa kuendesha usiku
     * fulani kwa sababu server ilikuwa imezimwa).
     */
    public void regenerateSnapshotForMonth(YearMonth yearMonth) {
        schedulerService.generateForMonth(yearMonth);
    }

    private Map<Long, BigDecimal> toMap(List<Object[]> rows) {
        Map<Long, BigDecimal> map = new HashMap<>();
        for (Object[] row : rows) {
            map.put((Long) row[0], (BigDecimal) row[1]);
        }
        return map;
    }
}