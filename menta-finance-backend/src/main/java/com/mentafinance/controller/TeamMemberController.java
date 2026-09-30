package com.mentafinance.controller;

import com.mentafinance.dto.request.TeamMemberRequest;
import com.mentafinance.dto.response.TeamMemberResponse;
import com.mentafinance.service.TeamMemberService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/team")
@RequiredArgsConstructor
public class TeamMemberController {

    private final TeamMemberService teamMemberService;

    // STAFF HAJATAJWA - hana ufikiaji kabisa, kama ilivyokubaliwa
    @PostMapping
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    @ResponseStatus(HttpStatus.CREATED)
    public TeamMemberResponse add(@Valid @RequestBody TeamMemberRequest request) {
        return teamMemberService.add(request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void remove(@PathVariable Long id) {
        teamMemberService.remove(id);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    public List<TeamMemberResponse> getAll() {
        return teamMemberService.getAllActive();
    }
}