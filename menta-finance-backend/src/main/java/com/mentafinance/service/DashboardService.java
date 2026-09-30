package com.mentafinance.service;

import com.mentafinance.dto.response.DashboardResponse;
import com.mentafinance.dto.response.ServicePerformanceResponse;
import com.mentafinance.dto.response.TransactionResponse;
import com.mentafinance.entity.Expense;
import com.mentafinance.entity.Income;
import com.mentafinance.entity.Project;
import com.mentafinance.entity.ServiceOffering;
import com.mentafinance.entity.enums.ProjectType;
import com.mentafinance.entity.enums.UserRole;
import com.mentafinance.repository.ExpenseRepository;
import com.mentafinance.repository.IncomeRepository;
import com.mentafinance.repository.ProjectRepository;
import com.mentafinance.repository.ServiceOfferingRepository;
import com.mentafinance.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Stream;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final IncomeRepository incomeRepository;
    private final ExpenseRepository expenseRepository;
    private final ProjectRepository projectRepository;
    private final ServiceOfferingRepository serviceOfferingRepository;

    public DashboardResponse getDashboard() {
        UserRole role = SecurityUtils.getCurrentUser().getRole();
        BigDecimal totalOutstanding = calculateTotalOutstanding();

        // STAFF: TU totalOutstanding, kama ilivyokubaliwa - hatuchoshi
        // database kuhesabu vitu ambavyo STAFF hataviona kabisa.
        if (role == UserRole.STAFF) {
            return DashboardResponse.builder()
                    .role(role.name())
                    .totalOutstanding(totalOutstanding)
                    .build();
        }

        // SUPERADMIN na MANAGER: dashboard kamili
        LocalDate start = LocalDate.now().withDayOfMonth(1);
        LocalDate end = LocalDate.now();

        BigDecimal incomeThisMonth = incomeRepository.sumAmountByDateRange(start, end);
        BigDecimal expensesThisMonth = expenseRepository.sumAmountByDateRange(start, end);
        BigDecimal netProfit = incomeThisMonth.subtract(expensesThisMonth);

        return DashboardResponse.builder()
                .role(role.name())
                .incomeThisMonth(incomeThisMonth)
                .expensesThisMonth(expensesThisMonth)
                .netProfit(netProfit)
                .totalOutstanding(totalOutstanding)
                .recentTransactions(getRecentTransactions(10))
                .performanceByService(getPerformanceByService(start, end))
                .build();
    }

    /**
     * Outstanding (dashboard) = jumla ya Outstanding za PROJECTS
     * ZOTE za aina CLIENT (siyo INTERNAL) ambazo bado hazijalipwa
     * kikamilifu - kama tulivyokubaliana: Outstanding (per project)
     * = project_value - jumla ya Income zake.
     */
    private BigDecimal calculateTotalOutstanding() {
        List<Project> clientProjects = projectRepository.findByProjectType(ProjectType.CLIENT);

        // Map ya "projectId -> jumla ya income" - QUERY MOJA TU,
        // siyo query moja kwa kila project (angalia comment kwenye
        // IncomeRepository.sumAmountGroupedByProject())
        Map<Long, BigDecimal> paidByProject = new HashMap<>();
        for (Object[] row : incomeRepository.sumAmountGroupedByProject()) {
            Long projectId = (Long) row[0];
            BigDecimal sum = (BigDecimal) row[1];
            paidByProject.put(projectId, sum);
        }

        BigDecimal total = BigDecimal.ZERO;
        for (Project project : clientProjects) {
            BigDecimal paid = paidByProject.getOrDefault(project.getId(), BigDecimal.ZERO);
            BigDecimal outstanding = project.getProjectValue().subtract(paid);
            if (outstanding.compareTo(BigDecimal.ZERO) > 0) {
                total = total.add(outstanding);
            }
        }
        return total;
    }

       private List<TransactionResponse> getRecentTransactions(int limit) {
        Stream<TransactionResponse> incomeTx = incomeRepository.findTop10ByOrderByIncomeDateDesc().stream()
                .map(this::toTransaction);

        Stream<TransactionResponse> expenseTx = expenseRepository.findTop10ByOrderByExpenseDateDesc().stream()
                .map(this::toTransaction);

        return Stream.concat(incomeTx, expenseTx)
                .sorted(Comparator.comparing(TransactionResponse::getDate).reversed())
                .limit(limit)
                .toList();
    }

    private TransactionResponse toTransaction(Income i) {
        return TransactionResponse.builder()
                .type("INCOME").date(i.getIncomeDate())
                .description(i.getDescription()).amount(i.getAmount())
                .build();
    }

    private TransactionResponse toTransaction(Expense e) {
        return TransactionResponse.builder()
                .type("EXPENSE").date(e.getExpenseDate())
                .description(e.getDescription()).amount(e.getAmount())
                .build();
    }

    /**
     * "Performance kwa Service" - kama ilivyoonekana kwenye picha zako
     * za awali (bar chart ya Wedding Video, Apartment Branding, n.k.)
     */
    private List<ServicePerformanceResponse> getPerformanceByService(LocalDate start, LocalDate end) {
        Map<Long, String> serviceNames = new HashMap<>();
        for (ServiceOffering s : serviceOfferingRepository.findAll()) {
            serviceNames.put(s.getId(), s.getName());
        }

        List<ServicePerformanceResponse> result = new ArrayList<>();
        for (Object[] row : incomeRepository.sumAmountGroupedByServiceForDateRange(start, end)) {
            Long serviceId = (Long) row[0];
            BigDecimal amount = (BigDecimal) row[1];
            result.add(ServicePerformanceResponse.builder()
                    .serviceId(serviceId)
                    .serviceName(serviceNames.getOrDefault(serviceId, "Haijulikani"))
                    .totalEarned(amount)
                    .build());
        }

        // Panga kutoka juu (performance kubwa zaidi) kwenda chini -
        // ndiyo mtindo uliouonyesha kwenye bar chart za awali
        result.sort(Comparator.comparing(ServicePerformanceResponse::getTotalEarned).reversed());
        return result;
    }
}