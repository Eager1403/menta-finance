package com.mentafinance.dto.request;

import com.mentafinance.entity.enums.ProjectStatus;
import com.mentafinance.entity.enums.ProjectType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Setter
public class ProjectRequest {

    @NotBlank(message = "Jina la project linahitajika")
    private String name;

    // Nullable kimakusudi - itahitajika TU kama projectType = CLIENT
    // (tutaithibitisha hii kwenye Service, siyo hapa)
    private Long clientId;

    private Long serviceId;

    @NotNull(message = "Aina ya project inahitajika (CLIENT au INTERNAL)")
    private ProjectType projectType;

    @NotNull(message = "Thamani ya project inahitajika")
    @PositiveOrZero(message = "Thamani ya project haiwezi kuwa hasi")
    private BigDecimal projectValue;

    private ProjectStatus status;

    private LocalDate startDate;
    private LocalDate endDate;
}