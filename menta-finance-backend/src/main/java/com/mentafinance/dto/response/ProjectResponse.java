package com.mentafinance.dto.response;

import com.mentafinance.entity.enums.ProjectStatus;
import com.mentafinance.entity.enums.ProjectType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Builder
@AllArgsConstructor
public class ProjectResponse {
    private Long id;
    private String name;
    private Long clientId;
    private String clientName;
    private Long serviceId;
    private String serviceName;
    private ProjectType projectType;
    private BigDecimal projectValue;
    private ProjectStatus status;
    private LocalDate startDate;
    private LocalDate endDate;
}