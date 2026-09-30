package com.mentafinance.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ServiceOfferingRequest {

    @NotBlank(message = "Jina la service linahitajika")
    private String name;

    private String description;
}