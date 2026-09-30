package com.mentafinance.controller;

import com.mentafinance.dto.request.IncomeRequest;
import com.mentafinance.dto.response.IncomeResponse;
import com.mentafinance.service.IncomeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/income")
@RequiredArgsConstructor
public class IncomeController {

    private final IncomeService incomeService;

    // STAFF anaweza Add income (kama ilivyokubaliwa)
    @PostMapping
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER','STAFF')")
    @ResponseStatus(HttpStatus.CREATED)
    public IncomeResponse create(@Valid @RequestBody IncomeRequest request) {
        return incomeService.create(request);
    }

    // Edit/Delete: SUPERADMIN na MANAGER pekee, ndani ya siku 7
    // (uthibitisho wa siku 7 upo ndani ya Service, siyo hapa)
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    public IncomeResponse update(@PathVariable Long id, @Valid @RequestBody IncomeRequest request) {
        return incomeService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        incomeService.delete(id);
    }

    @GetMapping("/project/{projectId}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    public List<IncomeResponse> getByProject(@PathVariable Long projectId) {
        return incomeService.getByProject(projectId);
    }
}