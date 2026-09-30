package com.mentafinance.repository;

import com.mentafinance.entity.ServicePerformanceMonthly;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface ServicePerformanceMonthlyRepository extends JpaRepository<ServicePerformanceMonthly, Long> {

    // Kwa Scheduled Job: kuangalia kama snapshot ya mwezi huu tayari ipo
    // (kuepuka kutengeneza mara mbili kwa bahati mbaya)
    Optional<ServicePerformanceMonthly> findByServiceIdAndYearMonth(Long serviceId, LocalDate yearMonth);

    // Kwa Reports: historia ya miezi kadhaa nyuma, kwa ajili ya trend chart
    List<ServicePerformanceMonthly> findByYearMonthBetweenOrderByYearMonthAsc(LocalDate start, LocalDate end);

    List<ServicePerformanceMonthly> findByServiceIdOrderByYearMonthAsc(Long serviceId);
}
