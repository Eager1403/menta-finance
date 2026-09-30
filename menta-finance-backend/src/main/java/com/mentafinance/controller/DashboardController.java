package com.mentafinance.controller;

import com.mentafinance.dto.response.DashboardResponse;
import com.mentafinance.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/api/dashboard")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER','STAFF')")
    public DashboardResponse getDashboard() {
        // Hatuhitaji kuangalia role hapa kwenye Controller - Service
        // layer ndiyo inayoamua "nini cha kurudisha" kutegemea role
        // ya mtumiaji aliye-login (angalia DashboardService.getDashboard())
        return dashboardService.getDashboard();
    }
}