package com.mentafinance.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;

@Getter
@Builder
@AllArgsConstructor
public class TeamMemberResponse {
    private Long id;
    private String fullName;
    private String position;
    private String phone;
    private String email;
    private LocalDate joinedDate;
    private Boolean active;
}