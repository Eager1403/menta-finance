package com.mentafinance.repository;

import com.mentafinance.entity.Project;
import com.mentafinance.entity.enums.ProjectStatus;
import com.mentafinance.entity.enums.ProjectType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ProjectRepository extends JpaRepository<Project, Long> {

    // Kwa Client Detail Page: "Client | Project | Price | Paid | Outstanding"
    List<Project> findByClientId(Long clientId);

    // Kwa Performance kwa Service: kupata projects zote za service fulani
    List<Project> findByServiceId(Long serviceId);

    List<Project> findByStatus(ProjectStatus status);

    List<Project> findByProjectType(ProjectType projectType);

    /**
     * Hii ni MUHIMU: itatumika kupata Project ya "Company Overhead"
     * (ile INTERNAL project tuliyoiweka kwenye seed data) badala ya
     * ku-hardcode ID yake namba (mf. project ID 1) popote kwenye code -
     * kutafuta kwa jina+type ni salama zaidi endapo ID itabadilika
     * kwenye mazingira tofauti (dev/test/production databases).
     */
    Optional<Project> findByProjectTypeAndNameIgnoreCase(ProjectType projectType, String name);

        @Query("SELECT COUNT(p) FROM Project p WHERE p.service.id = :serviceId")
    long countByServiceId(@Param("serviceId") Long serviceId);

    @Query("SELECT COUNT(DISTINCT p.client.id) FROM Project p WHERE p.service.id = :serviceId AND p.client IS NOT NULL")
    long countDistinctClientsByServiceId(@Param("serviceId") Long serviceId);

    @Query("SELECT COALESCE(AVG(p.projectValue), 0) FROM Project p WHERE p.service.id = :serviceId")
    java.math.BigDecimal avgProjectValueByServiceId(@Param("serviceId") Long serviceId);
}
