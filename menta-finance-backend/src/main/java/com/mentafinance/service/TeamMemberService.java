package com.mentafinance.service;

import com.mentafinance.dto.request.TeamMemberRequest;
import com.mentafinance.dto.response.TeamMemberResponse;
import com.mentafinance.entity.TeamMember;
import com.mentafinance.exception.ResourceNotFoundException;
import com.mentafinance.repository.TeamMemberRepository;
import com.mentafinance.repository.UserRepository;
import com.mentafinance.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TeamMemberService {

    private final TeamMemberRepository teamMemberRepository;
    private final UserRepository userRepository;

    @Transactional
    public TeamMemberResponse add(TeamMemberRequest request) {
        TeamMember member = TeamMember.builder()
                .fullName(request.getFullName())
                .position(request.getPosition())
                .phone(request.getPhone())
                .email(request.getEmail())
                .joinedDate(request.getJoinedDate() != null ? request.getJoinedDate() : LocalDate.now())
                .active(true)
                .addedBy(userRepository.getReferenceById(SecurityUtils.getCurrentUserId()))
                .build();

        return toResponse(teamMemberRepository.save(member));
    }

    /**
     * "Kuondoa" (remove) hapa ni SOFT DELETE (active=false), SIYO
     * kufuta rekodi kabisa - tunataka kubaki na historia ya nani
     * aliwahi kufanya kazi kampuni hii, kwa ajili ya rekodi za baadaye.
     */
    @Transactional
    public void remove(Long id) {
        TeamMember member = teamMemberRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Team member hayupo, ID: " + id));
        member.setActive(false);
        teamMemberRepository.save(member);
    }

    public List<TeamMemberResponse> getAllActive() {
        return teamMemberRepository.findByActiveTrue().stream().map(this::toResponse).toList();
    }

    private TeamMemberResponse toResponse(TeamMember m) {
        return TeamMemberResponse.builder()
                .id(m.getId()).fullName(m.getFullName()).position(m.getPosition())
                .phone(m.getPhone()).email(m.getEmail()).joinedDate(m.getJoinedDate())
                .active(m.getActive())
                .build();
    }
}