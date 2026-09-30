package com.mentafinance.controller;

import com.mentafinance.dto.request.ExpenseRequest;
import com.mentafinance.dto.response.ExpenseResponse;
import com.mentafinance.service.ExpenseService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/expenses")
@RequiredArgsConstructor
public class ExpenseController {

    private final ExpenseService expenseService;

    // MUHIMU: STAFF HAJATAJWA hapa kabisa - hasAnyRole ina SUPERADMIN
    // na MANAGER tu. STAFF akijaribu, atapata 403 Forbidden.
    @PostMapping
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    @ResponseStatus(HttpStatus.CREATED)
    public ExpenseResponse create(@Valid @RequestBody ExpenseRequest request) {
        return expenseService.create(request);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    public ExpenseResponse update(@PathVariable Long id, @Valid @RequestBody ExpenseRequest request) {
        return expenseService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        expenseService.delete(id);
    }

    @GetMapping("/project/{projectId}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    public List<ExpenseResponse> getByProject(@PathVariable Long projectId) {
        return expenseService.getByProject(projectId);
    }
}