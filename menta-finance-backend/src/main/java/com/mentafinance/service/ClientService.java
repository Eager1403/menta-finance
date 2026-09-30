package com.mentafinance.service;

import com.mentafinance.dto.request.ClientRequest;
import com.mentafinance.dto.response.ClientDetailResponse;
import com.mentafinance.dto.response.ClientResponse;
import com.mentafinance.dto.response.ProjectSummaryResponse;
import com.mentafinance.entity.Client;
import com.mentafinance.entity.Project;
import com.mentafinance.entity.User;
import com.mentafinance.exception.ResourceNotFoundException;
import com.mentafinance.repository.ClientRepository;
import com.mentafinance.repository.IncomeRepository;
import com.mentafinance.repository.ProjectRepository;
import com.mentafinance.repository.UserRepository;
import com.mentafinance.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ClientService {

    private final ClientRepository clientRepository;
    private final ProjectRepository projectRepository;
    private final IncomeRepository incomeRepository;
    private final UserRepository userRepository;

    @Transactional
    public ClientResponse create(ClientRequest request) {
        Client client = Client.builder()
                .name(request.getName())
                .phone(request.getPhone())
                .email(request.getEmail())
                .address(request.getAddress())
                // getReferenceById -> haiendi database KABISA hapa hapa,
                // inatengeneza tu "proxy" (ahadi) ya User mwenye ID hii.
                // Hibernate itaitumia tu wakati wa kuhifadhi Foreign Key -
                // hii ni haraka zaidi kuliko findById() kama hatuhitaji
                // fields nyingine za User (jina, email, n.k.) hapa.
                .createdBy(userRepository.getReferenceById(SecurityUtils.getCurrentUserId()))
                .build();

        Client saved = clientRepository.save(client);
        return toResponse(saved);
    }

    @Transactional
    public ClientResponse update(Long id, ClientRequest request) {
        Client client = findClientOrThrow(id);
        client.setName(request.getName());
        client.setPhone(request.getPhone());
        client.setEmail(request.getEmail());
        client.setAddress(request.getAddress());
        return toResponse(clientRepository.save(client));
    }

    @Transactional
    public void delete(Long id) {
        Client client = findClientOrThrow(id);
        clientRepository.delete(client);
    }

    public ClientResponse getById(Long id) {
        return toResponse(findClientOrThrow(id));
    }

    public List<ClientResponse> getAll() {
        return clientRepository.findAll().stream().map(this::toResponse).toList();
    }

    /**
     * Client Detail Page: "Client | Project | Price | Paid | Outstanding"
     */
    public ClientDetailResponse getClientDetail(Long clientId) {
        Client client = findClientOrThrow(clientId);
        List<Project> projects = projectRepository.findByClientId(clientId);

        List<ProjectSummaryResponse> summaries = projects.stream().map(project -> {
            BigDecimal paid = incomeRepository.sumAmountByProjectId(project.getId());
            BigDecimal outstanding = project.getProjectValue().subtract(paid);
            return ProjectSummaryResponse.builder()
                    .projectId(project.getId())
                    .projectName(project.getName())
                    .price(project.getProjectValue())
                    .paid(paid)
                    .outstanding(outstanding)
                    .build();
        }).toList();

        BigDecimal totalOutstanding = summaries.stream()
                .map(ProjectSummaryResponse::getOutstanding)
                .filter(o -> o.compareTo(BigDecimal.ZERO) > 0) // usiongeze outstanding hasi (project iliyolipwa zaidi)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return ClientDetailResponse.builder()
                .clientId(client.getId())
                .clientName(client.getName())
                .projects(summaries)
                .totalOutstanding(totalOutstanding)
                .build();
    }

    private Client findClientOrThrow(Long id) {
        return clientRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Client hayupo, ID: " + id));
    }

    private ClientResponse toResponse(Client client) {
        return ClientResponse.builder()
                .id(client.getId())
                .name(client.getName())
                .phone(client.getPhone())
                .email(client.getEmail())
                .address(client.getAddress())
                .createdAt(client.getCreatedAt())
                .build();
    }
}