package com.mentafinance.service;

import com.mentafinance.dto.request.ServiceOfferingRequest;
import com.mentafinance.dto.response.ServiceOfferingResponse;
import com.mentafinance.entity.ServiceOffering;
import com.mentafinance.exception.BusinessRuleException;
import com.mentafinance.exception.ResourceNotFoundException;
import com.mentafinance.repository.ServiceOfferingRepository;
import com.mentafinance.repository.UserRepository;
import com.mentafinance.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ServiceOfferingService {

    private final ServiceOfferingRepository serviceOfferingRepository;
    private final UserRepository userRepository;

    @Transactional
    public ServiceOfferingResponse create(ServiceOfferingRequest request) {
        if (serviceOfferingRepository.existsByNameIgnoreCase(request.getName())) {
            throw new BusinessRuleException("Service yenye jina hili tayari ipo: " + request.getName());
        }

        ServiceOffering entity = ServiceOffering.builder()
                .name(request.getName())
                .description(request.getDescription())
                .active(true)
                .createdBy(userRepository.getReferenceById(SecurityUtils.getCurrentUserId()))
                .build();

        return toResponse(serviceOfferingRepository.save(entity));
    }

    @Transactional
    public ServiceOfferingResponse update(Long id, ServiceOfferingRequest request) {
        ServiceOffering entity = findOrThrow(id);
        entity.setName(request.getName());
        entity.setDescription(request.getDescription());
        return toResponse(serviceOfferingRepository.save(entity));
    }

    @Transactional
    public void deactivate(Long id) {
        // Hatufuti Services kabisa (delete) - tunazi-"zima" (deactivate)
        // kwa sababu Projects za nyuma zinaweza kuwa zinazitegemea kwa
        // ajili ya ripoti za Performance - kufuta kungevunja historia.
        ServiceOffering entity = findOrThrow(id);
        entity.setActive(false);
        serviceOfferingRepository.save(entity);
    }

    public List<ServiceOfferingResponse> getAllActive() {
        return serviceOfferingRepository.findByActiveTrue().stream().map(this::toResponse).toList();
    }

    private ServiceOffering findOrThrow(Long id) {
        return serviceOfferingRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Service haipo, ID: " + id));
    }

    private ServiceOfferingResponse toResponse(ServiceOffering s) {
        return ServiceOfferingResponse.builder()
                .id(s.getId()).name(s.getName()).description(s.getDescription()).active(s.getActive())
                .build();
    }
}