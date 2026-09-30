package com.mentafinance.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class ServiceOfferingResponse {
    private Long id;
    private String name;
    private String description;
    private Boolean active;
}