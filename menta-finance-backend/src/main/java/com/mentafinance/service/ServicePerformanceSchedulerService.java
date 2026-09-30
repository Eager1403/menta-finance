package com.mentafinance.service;

import com.mentafinance.entity.ServiceOffering;
import com.mentafinance.entity.ServicePerformanceMonthly;
import com.mentafinance.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * @Slf4j (Lombok) -> inatengeneza "log" object kiotomatiki, hivyo
 * tunaweza kuandika log.info(...) badala ya kutengeneza Logger
 * wenyewe kwa mkono - muhimu hasa kwa Scheduled Jobs, kwa sababu
 * hakuna mtu "anayeziangalia" moja kwa moja; logs ndizo njia pekee
 * ya kujua zilifanya kazi vizuri au la.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ServicePerformanceSchedulerService {

    private final ServiceOfferingRepository serviceOfferingRepository;
    private final IncomeRepository incomeRepository;
    private final ExpenseRepository expenseRepository;
    private final ProjectRepository projectRepository;
    private final ServicePerformanceMonthlyRepository performanceRepository;

    /**
     * Cron: "sekunde dakika saa siku-ya-mwezi mwezi siku-ya-wiki"
     * "0 5 0 1 * *" = sekunde-0 dakika-5 saa-00 (00:05 usiku),
     * siku-ya-1 ya kila mwezi, kila mwezi, siku yoyote ya wiki.
     *
     * Kwa nini 00:05 tarehe 1 na siyo saa sita usiku (00:00)?
     * Kutoa nafasi kidogo ya "buffer" endapo kuna operesheni nyingine
     * za usiku wa manane zinazoendana na server (mf. backups) - kuepuka
     * migongano ya rasilimali (resource contention).
     */
    @Scheduled(cron = "0 5 0 1 * *")
    public void runMonthlySnapshot() {
        YearMonth lastMonth = YearMonth.now().minusMonths(1);
        log.info("Kuanza kutengeneza Service Performance snapshot kwa mwezi: {}", lastMonth);
        generateForMonth(lastMonth);
        log.info("Snapshot ya mwezi {} imekamilika", lastMonth);
    }

    /**
     * Method hii ni PUBLIC na inatumika PIA na ReportController
     * kwa "manual trigger" (backfill ya miezi ya nyuma, au testing
     * bila kusubiri cron ifike) - tazama ReportService/ReportController.
     */
    @Transactional
    public void generateForMonth(YearMonth yearMonth) {
        LocalDate start = yearMonth.atDay(1);
        LocalDate end = yearMonth.atEndOfMonth();
        LocalDate yearMonthDate = start; // tunahifadhi "siku ya kwanza" kuwakilisha mwezi mzima

        Map<Long, BigDecimal> incomeByService = toMap(incomeRepository.sumAmountGroupedByServiceForDateRange(start, end));
        Map<Long, BigDecimal> expenseByService = toMap(expenseRepository.sumAmountGroupedByServiceForDateRange(start, end));

        List<ServiceOffering> allServices = serviceOfferingRepository.findAll();

        for (ServiceOffering service : allServices) {
            BigDecimal income = incomeByService.getOrDefault(service.getId(), BigDecimal.ZERO);
            BigDecimal expense = expenseByService.getOrDefault(service.getId(), BigDecimal.ZERO);
            BigDecimal netProfit = income.subtract(expense);

            long projectCount = projectRepository.countByServiceId(service.getId());
            long clientCount = projectRepository.countDistinctClientsByServiceId(service.getId());
            BigDecimal avgProjectValue = projectRepository.avgProjectValueByServiceId(service.getId());

            // UPSERT: tafuta kama tayari ipo (endapo job imeendeshwa
            // mara mbili kwa bahati mbaya kwa mwezi huo huo), kama
            // ipo IBADILISHE badala ya kuunda nakala mpya (kumbuka
            // UNIQUE constraint (service_id, year_month) tuliyoweka
            // kwenye database - bila logic hii, save ya pili
            // ingetupa error ya "duplicate key").
            ServicePerformanceMonthly snapshot = performanceRepository
                    .findByServiceIdAndYearMonth(service.getId(), yearMonthDate)
                    .orElseGet(() -> ServicePerformanceMonthly.builder()
                            .service(service)
                            .yearMonth(yearMonthDate)
                            .build());

            snapshot.setTotalIncome(income);
            snapshot.setTotalExpense(expense);
            snapshot.setNetProfit(netProfit);
            snapshot.setProjectCount((int) projectCount);
            snapshot.setClientCount((int) clientCount);
            snapshot.setAvgProjectValue(avgProjectValue);

            performanceRepository.save(snapshot);
        }
    }

    private Map<Long, BigDecimal> toMap(List<Object[]> rows) {
        Map<Long, BigDecimal> map = new HashMap<>();
        for (Object[] row : rows) {
            map.put((Long) row[0], (BigDecimal) row[1]);
        }
        return map;
    }
}