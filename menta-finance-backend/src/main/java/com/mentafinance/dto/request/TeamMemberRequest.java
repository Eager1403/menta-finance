package com.mentafinance.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class TeamMemberRequest {

    @NotBlank(message = "Jina linahitajika")
    private String fullName;

    private String position;
    private String phone;
    private String email;
    private LocalDate joinedDate;
}