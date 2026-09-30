package com.mentafinance.service;

import com.mentafinance.dto.request.IncomeRequest;
import com.mentafinance.dto.response.IncomeResponse;
import com.mentafinance.entity.Income;
import com.mentafinance.entity.Project;
import com.mentafinance.entity.enums.IncomeSource;
import com.mentafinance.exception.BusinessRuleException;
import com.mentafinance.exception.ResourceNotFoundException;
import com.mentafinance.repository.IncomeRepository;
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
public class IncomeService {

    private final IncomeRepository incomeRepository;
    private final ProjectRepository projectRepository;
    private final UserRepository userRepository;

    @Transactional
    public IncomeResponse create(IncomeRequest request) {
        Project project = projectRepository.findById(request.getProjectId())
                .orElseThrow(() -> new ResourceNotFoundException("Project haipo, ID: " + request.getProjectId()));

        Income income = Income.builder()
                .project(project)
                .description(request.getDescription())
                .amount(request.getAmount())
                .incomeDate(request.getIncomeDate() != null ? request.getIncomeDate() : LocalDate.now())
                .paymentMethod(request.getPaymentMethod())
                // sourceType ni MANUAL LAZIMA hapa - hatuachi mtumiaji
                // achague sourceType mwenyewe kupitia hii DTO. INVOICE_PAYMENT
                // itawekwa TU na InvoiceService, siyo endpoint hii.
                .sourceType(IncomeSource.MANUAL)
                .recordedBy(userRepository.getReferenceById(SecurityUtils.getCurrentUserId()))
                .build();

        return toResponse(incomeRepository.save(income));
    }

    @Transactional
    public IncomeResponse update(Long id, IncomeRequest request) {
        Income income = findOrThrow(id);
        guardAgainstInvoicePaymentSource(income);
        EditWindowValidator.checkWithinEditWindow(income.getCreatedAt());

        Project project = projectRepository.findById(request.getProjectId())
                .orElseThrow(() -> new ResourceNotFoundException("Project haipo, ID: " + request.getProjectId()));

        income.setProject(project);
        income.setDescription(request.getDescription());
        income.setAmount(request.getAmount());
        if (request.getIncomeDate() != null) income.setIncomeDate(request.getIncomeDate());
        income.setPaymentMethod(request.getPaymentMethod());

        return toResponse(incomeRepository.save(income));
    }

    @Transactional
    public void delete(Long id) {
        Income income = findOrThrow(id);
        guardAgainstInvoicePaymentSource(income);
        EditWindowValidator.checkWithinEditWindow(income.getCreatedAt());
        incomeRepository.delete(income);
    }

    public List<IncomeResponse> getByProject(Long projectId) {
        return incomeRepository.findByProjectId(projectId).stream().map(this::toResponse).toList();
    }

    /**
     * Income yenye source_type = INVOICE_PAYMENT haiwezi kuguswa
     * hapa - lazima ipitie InvoicePayment endpoints (Hatua ya 8),
     * kama tulivyokubaliana - kuepuka data ya invoice na income
     * kutofautiana (kuwa "out of sync").
     */
    private void guardAgainstInvoicePaymentSource(Income income) {
        if (income.getSourceType() == IncomeSource.INVOICE_PAYMENT) {
            throw new BusinessRuleException(
                "Income hii ilitokana na malipo ya Invoice - haiwezi kuhaririwa/kufutwa hapa. " +
                "Nenda kwenye Invoice husika kubadilisha malipo yake."
            );
        }
    }

    private Income findOrThrow(Long id) {
        return incomeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Income haipo, ID: " + id));
    }

    private IncomeResponse toResponse(Income i) {
        return IncomeResponse.builder()
                .id(i.getId())
                .projectId(i.getProject().getId())
                .projectName(i.getProject().getName())
                .description(i.getDescription())
                .amount(i.getAmount())
                .incomeDate(i.getIncomeDate())
                .paymentMethod(i.getPaymentMethod())
                .sourceType(i.getSourceType())
                .build();
    }
}