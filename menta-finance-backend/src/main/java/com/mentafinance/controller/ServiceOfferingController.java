package com.mentafinance.controller;

import com.mentafinance.dto.request.ServiceOfferingRequest;
import com.mentafinance.dto.response.ServiceOfferingResponse;
import com.mentafinance.service.ServiceOfferingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/services")
@RequiredArgsConstructor
public class ServiceOfferingController {

    private final ServiceOfferingService serviceOfferingService;

    // Roles ZOTE tatu zinaweza ku-Add (kama ilivyokubaliwa)
    @PostMapping
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER','STAFF')")
    @ResponseStatus(HttpStatus.CREATED)
    public ServiceOfferingResponse create(@Valid @RequestBody ServiceOfferingRequest request) {
        return serviceOfferingService.create(request);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    public ServiceOfferingResponse update(@PathVariable Long id, @Valid @RequestBody ServiceOfferingRequest request) {
        return serviceOfferingService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER')")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deactivate(@PathVariable Long id) {
        serviceOfferingService.deactivate(id);
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('SUPERADMIN','MANAGER','STAFF')")
    public List<ServiceOfferingResponse> getAll() {
        return serviceOfferingService.getAllActive();
    }
}