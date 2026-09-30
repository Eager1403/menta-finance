package com.mentafinance.controller;

import com.mentafinance.dto.request.LoginRequest;
import com.mentafinance.dto.response.LoginResponse;
import com.mentafinance.security.CustomUserDetails;
import com.mentafinance.security.JwtUtil;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;

    @PostMapping("/login")
    public LoginResponse login(@Valid @RequestBody LoginRequest request) {

        // AuthenticationManager ndiye "hakimu": anatumia CustomUserDetailsService
        // + PasswordEncoder (kulinganisha password na hash) - akikataa,
        // ata-throw BadCredentialsException moja kwa moja.
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        String token = jwtUtil.generateToken(userDetails);

        return LoginResponse.builder()
                .token(token)
                .fullName(userDetails.getFullName())
                .email(userDetails.getUsername())
                .role(userDetails.getRole())
                .build();
    }
}