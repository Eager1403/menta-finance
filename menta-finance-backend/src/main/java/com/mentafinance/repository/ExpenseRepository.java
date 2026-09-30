package com.mentafinance.repository;

import com.mentafinance.entity.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public interface ExpenseRepository extends JpaRepository<Expense, Long> {

    List<Expense> findByProjectId(Long projectId);

    List<Expense> findByExpenseDateBetweenOrderByExpenseDateDesc(LocalDate start, LocalDate end);

    @Query("SELECT COALESCE(SUM(e.amount), 0) FROM Expense e WHERE e.project.id = :projectId")
    BigDecimal sumAmountByProjectId(@Param("projectId") Long projectId);

    @Query("SELECT COALESCE(SUM(e.amount), 0) FROM Expense e WHERE e.expenseDate BETWEEN :start AND :end")
    BigDecimal sumAmountByDateRange(@Param("start") LocalDate start, @Param("end") LocalDate end);

    @Query("SELECT e.project.service.id, COALESCE(SUM(e.amount), 0) " +
           "FROM Expense e " +
           "WHERE e.expenseDate BETWEEN :start AND :end AND e.project.service IS NOT NULL " +
           "GROUP BY e.project.service.id")
    List<Object[]> sumAmountGroupedByServiceForDateRange(@Param("start") LocalDate start,
                                                           @Param("end") LocalDate end);
    // Kwa Dashboard "Transactions za hivi karibuni"
    List<Expense> findTop10ByOrderByExpenseDateDesc();
}
