package com.mentafinance.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
@AllArgsConstructor
public class ClientResponse {
    private Long id;
    private String name;
    private String phone;
    private String email;
    private String address;
    private LocalDateTime createdAt;
}