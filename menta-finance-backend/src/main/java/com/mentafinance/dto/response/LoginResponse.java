package com.mentafinance.dto.response;

import com.mentafinance.entity.enums.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class LoginResponse {
    private String token;
    private String fullName;
    private String email;
    private UserRole role;
}