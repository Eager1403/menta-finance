package com.mentafinance.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ClientRequest {

    @NotBlank(message = "Jina la client linahitajika")
    private String name;

    private String phone;
    private String email;
    private String address;
}