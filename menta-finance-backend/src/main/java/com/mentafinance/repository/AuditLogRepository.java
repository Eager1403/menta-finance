package com.mentafinance.repository;

import com.mentafinance.entity.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {

    List<AuditLog> findByEntityNameAndEntityIdOrderByPerformedAtDesc(String entityName, Long entityId);
}
