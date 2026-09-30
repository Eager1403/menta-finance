package com.mentafinance.controller;

import com.mentafinance.dto.request.ClientRequest;
import com.mentafinance.dto.response.ClientDetailResponse;
import com.mentafinance.dto.response.ClientResponse;
import com.mentafinance.service.ClientService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/clients")
@RequiredArgsConstructor
public class ClientController {

    private final ClientService clientService;

    /**
     * hasAnyRole('SUPERADMIN','MANAGER','STAFF') -> WOTE watatu
     * wanaweza ku-CREATE (Add), kama ilivyokubaliwa kwenye
     * permissions matrix yetu.
     *
     * Spring Security inaongeza "ROLE_" kiotomatiki mbele ya jina -
     * ndiyo maana CustomUserDetails.getAuthorities() tuliyoiandika
     * awali inaongeza "ROLE_" yenyewe kwenye SimpleGrantedAuthority.
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER','STAFF')")
    @ResponseStatus(HttpStatus.CREATED)
    public ClientResponse create(@Valid @RequestBody ClientRequest request) {
        return clientService.create(request);
    }

    // Edit/Delete: SUPERADMIN na MANAGER pekee (STAFF hana ruhusa hii)
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    public ClientResponse update(@PathVariable Long id, @Valid @RequestBody ClientRequest request) {
        return clientService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        clientService.delete(id);
    }

    // Kuona list na detail - roles zote tatu zinaruhusiwa
    @GetMapping
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER','STAFF')")
    public List<ClientResponse> getAll() {
        return clientService.getAll();
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER','STAFF')")
    public ClientResponse getById(@PathVariable Long id) {
        return clientService.getById(id);
    }

    @GetMapping("/{id}/detail")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER','STAFF')")
    public ClientDetailResponse getDetail(@PathVariable Long id) {
        return clientService.getClientDetail(id);
    }
}