package com.mentafinance.controller;

import com.mentafinance.dto.request.CreateUserRequest;
import com.mentafinance.dto.response.UserResponse;
import com.mentafinance.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * SUPERADMIN PEKEE kwenye moduli hii YOTE - kuunda akaunti mpya
 * (Manager/Staff) ni uwezo mzito sana (mtu mwenye account mpya
 * anapata ufikiaji wa mfumo), kwa hiyo hatuwapi hata MANAGER
 * ruhusa hii, kulingana na permissions matrix yetu.
 */
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@PreAuthorize("hasRole('SUPERADMIN')")
public class UserController {

    private final UserService userService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserResponse create(@Valid @RequestBody CreateUserRequest request) {
        return userService.create(request);
    }

    @PutMapping("/{id}/deactivate")
    public void deactivate(@PathVariable Long id) {
        userService.deactivate(id);
    }

    @PutMapping("/{id}/reactivate")
    public void reactivate(@PathVariable Long id) {
        userService.reactivate(id);
    }

    @GetMapping
    public List<UserResponse> getAll() {
        return userService.getAll();
    }
}