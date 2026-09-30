package com.mentafinance.service;

import com.mentafinance.dto.request.ExpenseRequest;
import com.mentafinance.dto.response.ExpenseResponse;
import com.mentafinance.entity.Expense;
import com.mentafinance.entity.Project;
import com.mentafinance.exception.ResourceNotFoundException;
import com.mentafinance.repository.ExpenseRepository;
import com.mentafinance.repository.ProjectRepository;
import com.mentafinance.repository.UserRepository;
import com.mentafinance.security.SecurityUtils;
import com.mentafinance.util.EditWindowValidator;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ExpenseService {

    private final ExpenseRepository expenseRepository;
    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;

    @Transactional
    public ExpenseResponse create(ExpenseRequest request) {
        Project project = projectRepository.findById(request.getProjectId())
                .orElseThrow(() -> new ResourceNotFoundException("Project haipo, ID: " + request.getProjectId()));

        Expense expense = Expense.builder()
                .project(project)
                .description(request.getDescription())
                .amount(request.getAmount())
                .expenseDate(request.getExpenseDate() != null ? request.getExpenseDate() : LocalDate.now())
                .category(request.getCategory())
                .recordedBy(userRepository.getReferenceById(SecurityUtils.getCurrentUserId()))
                .build();

        return toResponse(expenseRepository.save(expense));
    }

    @Transactional
    public ExpenseResponse update(Long id, ExpenseRequest request) {
        Expense expense = findOrThrow(id);
        EditWindowValidator.checkWithinEditWindow(expense.getCreatedAt());

        Project project = projectRepository.findById(request.getProjectId())
                .orElseThrow(() -> new ResourceNotFoundException("Project haipo, ID: " + request.getProjectId()));

        expense.setProject(project);
        expense.setDescription(request.getDescription());
        expense.setAmount(request.getAmount());
        if (request.getExpenseDate() != null) expense.setExpenseDate(request.getExpenseDate());
        expense.setCategory(request.getCategory());

        return toResponse(expenseRepository.save(expense));
    }

    @Transactional
    public void delete(Long id) {
        Expense expense = findOrThrow(id);
        EditWindowValidator.checkWithinEditWindow(expense.getCreatedAt());
        expenseRepository.delete(expense);
    }

    public List<ExpenseResponse> getByProject(Long projectId) {
        return expenseRepository.findByProjectId(projectId).stream().map(this::toResponse).toList();
    }

    private Expense findOrThrow(Long id) {
        return expenseRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Expense haipo, ID: " + id));
    }

    private ExpenseResponse toResponse(Expense e) {
        return ExpenseResponse.builder()
                .id(e.getId())
                .projectId(e.getProject().getId())
                .projectName(e.getProject().getName())
                .description(e.getDescription())
                .amount(e.getAmount())
                .expenseDate(e.getExpenseDate())
                .category(e.getCategory())
                .build();
    }
}