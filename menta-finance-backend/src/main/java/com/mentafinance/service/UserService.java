package com.mentafinance.service;

import com.mentafinance.dto.request.CreateUserRequest;
import com.mentafinance.dto.response.UserResponse;
import com.mentafinance.entity.User;
import com.mentafinance.exception.BusinessRuleException;
import com.mentafinance.exception.ResourceNotFoundException;
import com.mentafinance.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    // Hii ni ile ile BCryptPasswordEncoder Bean tuliyoiunda kwenye
    // SecurityConfig - Spring inai-"inject" hapa kiotomatiki kwa
    // sababu ya @RequiredArgsConstructor (constructor injection)
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public UserResponse create(CreateUserRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BusinessRuleException("Email hii tayari inatumika: " + request.getEmail());
        }

        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                // KAMWE hatuhifadhi password ya wazi (plain text) -
                // .encode() inaifanya kuwa BCrypt hash MARA MOJA,
                // kabla ya kuigusa database hata kidogo.
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .role(request.getRole())
                .active(true)
                .build();

        return toResponse(userRepository.save(user));
    }

    /**
     * Soft-deactivate (siyo delete kabisa) - kama TeamMember, tunataka
     * kubaki na historia ya nani aliwahi kuwa na akaunti (audit trail),
     * na pia rekodi zote alizowahi kuunda (Income, Invoice, n.k.)
     * zinaendelea kuonyesha jina lake kwa usahihi.
     */
    @Transactional
    public void deactivate(Long id) {
        User user = findOrThrow(id);
        user.setActive(false);
        userRepository.save(user);
    }

    @Transactional
    public void reactivate(Long id) {
        User user = findOrThrow(id);
        user.setActive(true);
        userRepository.save(user);
    }

    public List<UserResponse> getAll() {
        return userRepository.findAll().stream().map(this::toResponse).toList();
    }

    private User findOrThrow(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User hayupo, ID: " + id));
    }

    private UserResponse toResponse(User u) {
        return UserResponse.builder()
                .id(u.getId())
                .fullName(u.getFullName())
                .email(u.getEmail())
                .role(u.getRole())
                .active(u.getActive())
                .createdAt(u.getCreatedAt())
                .build();
    }
}