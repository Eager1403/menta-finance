package com.mentafinance.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * MUHIMU: Hii SIYO login account (angalia User.java kwa hilo).
 * Ni orodha tu ya wafanyakazi (Staff) ambao Manager anaweza
 * ku-add/kuondoa, kama ilivyokubaliwa.
 */
@Entity
@Table(name = "team_members")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TeamMember {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "full_name", nullable = false, length = 150)
    private String fullName;

    @Column(length = 100)
    private String position;

    @Column(length = 30)
    private String phone;

    @Column(length = 150)
    private String email;

    @Column(name = "joined_date")
    private LocalDate joinedDate;

    @Column(nullable = false)
    @Builder.Default
    private Boolean active = true;

    /**
     * "added_by" -> Manager (au SuperAdmin) aliyemuongeza huyu
     * team member. Tunatumia User kwa sababu ndiye mwenye login account.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "added_by")
    private User addedBy;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
