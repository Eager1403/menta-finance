package com.mentafinance.controller;

import com.mentafinance.dto.response.ServicePerformanceMonthResponse;
import com.mentafinance.service.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.YearMonth;
import java.util.List;

@RestController
@RequestMapping("/api/reports")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    // MUHIMU: hasRole (siyo hasAnyRole) - SUPERADMIN PEKEE, kama
    // ilivyokubaliwa mara nyingi kwenye majadiliano yetu
    @GetMapping("/service-performance")
    @PreAuthorize("hasRole('SUPERADMIN')")
    public List<ServicePerformanceMonthResponse> getServicePerformance(
            @RequestParam(defaultValue = "6") int monthsBack) {
        return reportService.getServicePerformanceHistory(monthsBack);
    }

    // Kwa "backfill" ya dharura - format ya month: "2026-08"
    @PostMapping("/service-performance/regenerate")
    @PreAuthorize("hasRole('SUPERADMIN')")
    public void regenerateSnapshot(@RequestParam String month) {
        reportService.regenerateSnapshotForMonth(YearMonth.parse(month));
    }
}