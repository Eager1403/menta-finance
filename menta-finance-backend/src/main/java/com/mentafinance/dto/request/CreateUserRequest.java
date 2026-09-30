package com.mentafinance.dto.request;

import com.mentafinance.entity.enums.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateUserRequest {

    @NotBlank(message = "Jina linahitajika")
    private String fullName;

    @NotBlank(message = "Email inahitajika")
    @Email(message = "Email si sahihi")
    private String email;

    @NotBlank(message = "Password inahitajika")
    @Size(min = 8, message = "Password lazima iwe angalau herufi 8")
    private String password;

    @NotNull(message = "Role inahitajika")
    private UserRole role;
}