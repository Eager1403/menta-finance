package com.mentafinance.dto.response;

import com.mentafinance.entity.enums.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
@AllArgsConstructor
public class UserResponse {
    private Long id;
    private String fullName;
    private String email;
    private UserRole role;
    private Boolean active;
    private LocalDateTime createdAt;
    // MUHIMU: hatuweki passwordHash hapa KABISA - hata kama ni hash
    // (siyo plain text), bado haipaswi kutoka nje ya server kamwe.
}