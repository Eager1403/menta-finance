package com.mentafinance.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ServicePerformanceResponse {
    private Long serviceId;
    private String serviceName;
    private BigDecimal totalEarned;
}