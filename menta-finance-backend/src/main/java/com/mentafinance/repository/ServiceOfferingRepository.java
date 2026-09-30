package com.mentafinance.repository;

import com.mentafinance.entity.ServiceOffering;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ServiceOfferingRepository extends JpaRepository<ServiceOffering, Long> {

    // Kwa Services screen - onyesha tu zile ambazo hazijazimwa (active)
    List<ServiceOffering> findByActiveTrue();

    boolean existsByNameIgnoreCase(String name);
}
