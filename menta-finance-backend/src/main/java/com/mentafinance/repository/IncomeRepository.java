package com.mentafinance.repository;

import com.mentafinance.entity.Income;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public interface IncomeRepository extends JpaRepository<Income, Long> {

    List<Income> findByProjectId(Long projectId);

    List<Income> findByIncomeDateBetweenOrderByIncomeDateDesc(LocalDate start, LocalDate end);

    /**
     * @Query -> tunapoandika query yenyewe kwa JPQL (Java Persistence
     *   Query Language). JPQL ni "kama SQL" lakini inatumia MAJINA YA
     *   JAVA CLASS/FIELD (Income, i.amount) SIYO majina ya column za
     *   database (income, amount) - Hibernate ndiye anayeyabadilisha
     *   kuwa SQL halisi nyuma ya pazia.
     *
     * COALESCE(SUM(i.amount), 0) -> Ikiwa hakuna records kabisa
     *   zinazoendana (mf. project mpya bila income yoyote), SUM
     *   ya kawaida inarudisha NULL - COALESCE inaibadilisha kuwa 0
     *   badala yake, kuepuka NullPointerException kwenye Java code.
     *
     * :projectId -> "named parameter", inaendana na @Param("projectId")
     *   kwenye method signature chini.
     */
    @Query("SELECT COALESCE(SUM(i.amount), 0) FROM Income i WHERE i.project.id = :projectId")
    BigDecimal sumAmountByProjectId(@Param("projectId") Long projectId);

    // Kwa Dashboard "Income ya mwezi": jumla ya income zote kati ya tarehe mbili
    @Query("SELECT COALESCE(SUM(i.amount), 0) FROM Income i WHERE i.incomeDate BETWEEN :start AND :end")
    BigDecimal sumAmountByDateRange(@Param("start") LocalDate start, @Param("end") LocalDate end);

    /**
     * Kwa "Performance kwa Service": tunapita kupitia Project kufika
     * Service (i.project.service.id) - hii ni "implicit join" ya JPQL,
     * Hibernate itatengeneza SQL JOIN inayohitajika yenyewe.
     *
     * Result ni List<Object[]> ambapo kila Object[] ina:
     *   [0] = serviceId (Long), [1] = jumla ya income (BigDecimal)
     * Tutaibadilisha kuwa DTO safi kwenye Service layer.
     */
    @Query("SELECT i.project.service.id, COALESCE(SUM(i.amount), 0) " +
           "FROM Income i " +
           "WHERE i.incomeDate BETWEEN :start AND :end AND i.project.service IS NOT NULL " +
           "GROUP BY i.project.service.id")
    List<Object[]> sumAmountGroupedByServiceForDateRange(@Param("start") LocalDate start,
                                                           @Param("end") LocalDate end);

    // Kwa Dashboard "Transactions za hivi karibuni"
    List<Income> findTop10ByOrderByIncomeDateDesc();

    /**
     * Kwa Outstanding ya jumla (dashboard): tunahitaji kujua kila
     * project imelipwa kiasi gani, kwa QUERY MOJA (badala ya kuuliza
     * database mara moja kwa kila project - hiyo ingekuwa "N+1 query
     * problem" - polepole sana ikiwa projects ni nyingi).
     */
    @Query("SELECT i.project.id, COALESCE(SUM(i.amount), 0) FROM Income i GROUP BY i.project.id")
    List<Object[]> sumAmountGroupedByProject();                                                        }
