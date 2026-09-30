package com.mentafinance.service;

import com.mentafinance.dto.request.ProjectRequest;
import com.mentafinance.dto.response.ProjectResponse;
import com.mentafinance.entity.Client;
import com.mentafinance.entity.Project;
import com.mentafinance.entity.ServiceOffering;
import com.mentafinance.entity.enums.ProjectStatus;
import com.mentafinance.entity.enums.ProjectType;
import com.mentafinance.exception.BusinessRuleException;
import com.mentafinance.exception.ResourceNotFoundException;
import com.mentafinance.repository.ClientRepository;
import com.mentafinance.repository.ProjectRepository;
import com.mentafinance.repository.ServiceOfferingRepository;
import com.mentafinance.repository.UserRepository;
import com.mentafinance.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProjectService {

    private final ProjectRepository projectRepository;
    private final ClientRepository clientRepository;
    private final ServiceOfferingRepository serviceOfferingRepository;
    private final UserRepository userRepository;

    @Transactional
    public ProjectResponse create(ProjectRequest request) {
        validateClientRequirement(request);

        Project project = Project.builder()
                .name(request.getName())
                .client(request.getClientId() != null ? clientRepository.getReferenceById(request.getClientId()) : null)
                .service(request.getServiceId() != null ? serviceOfferingRepository.getReferenceById(request.getServiceId()) : null)
                .projectType(request.getProjectType())
                .projectValue(request.getProjectValue())
                .status(request.getStatus() != null ? request.getStatus() : ProjectStatus.ONGOING)
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .createdBy(userRepository.getReferenceById(SecurityUtils.getCurrentUserId()))
                .build();

        return toResponse(projectRepository.save(project));
    }

    @Transactional
    public ProjectResponse update(Long id, ProjectRequest request) {
        validateClientRequirement(request);
        Project project = findOrThrow(id);

        project.setName(request.getName());
        project.setClient(request.getClientId() != null ? clientRepository.getReferenceById(request.getClientId()) : null);
        project.setService(request.getServiceId() != null ? serviceOfferingRepository.getReferenceById(request.getServiceId()) : null);
        project.setProjectType(request.getProjectType());
        project.setProjectValue(request.getProjectValue());
        if (request.getStatus() != null) project.setStatus(request.getStatus());
        project.setStartDate(request.getStartDate());
        project.setEndDate(request.getEndDate());

        return toResponse(projectRepository.save(project));
    }

    @Transactional
    public void delete(Long id) {
        Project project = findOrThrow(id);
        projectRepository.delete(project);
    }

    public ProjectResponse getById(Long id) {
        return toResponse(findOrThrow(id));
    }

    public List<ProjectResponse> getAll() {
        return projectRepository.findAll().stream().map(this::toResponse).toList();
    }

    /**
     * Sheria ya biashara: "CLIENT project LAZIMA iwe na client_id"
     * (INTERNAL haihitaji). Hii ni SAWA na CHECK constraint kwenye
     * database (chk_client_required), lakini tunaithibitisha HAPA
     * pia ili mtumiaji apate ujumbe MZURI wa Kiswahili badala ya
     * database error ya kiufundi isiyoeleweka.
     */
    private void validateClientRequirement(ProjectRequest request) {
        if (request.getProjectType() == ProjectType.CLIENT && request.getClientId() == null) {
            throw new BusinessRuleException("Project ya aina CLIENT lazima iwe na client_id");
        }
    }

    private Project findOrThrow(Long id) {
        return projectRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Project haipo, ID: " + id));
    }

    private ProjectResponse toResponse(Project p) {
        return ProjectResponse.builder()
                .id(p.getId())
                .name(p.getName())
                .clientId(p.getClient() != null ? p.getClient().getId() : null)
                .clientName(p.getClient() != null ? p.getClient().getName() : null)
                .serviceId(p.getService() != null ? p.getService().getId() : null)
                .serviceName(p.getService() != null ? p.getService().getName() : null)
                .projectType(p.getProjectType())
                .projectValue(p.getProjectValue())
                .status(p.getStatus())
                .startDate(p.getStartDate())
                .endDate(p.getEndDate())
                .build();
    }
}