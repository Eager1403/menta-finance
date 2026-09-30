package com.mentafinance.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "clients")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Client {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String name;

    @Column(length = 30)
    private String phone;

    @Column(length = 150)
    private String email;

    @Column(columnDefinition = "TEXT")
    private String address;

    /**
     * @ManyToOne -> Clients wengi wanaweza kuundwa na User mmoja
     *   (relationship: Client MOJA ina User MMOJA aliyemuunda,
     *   lakini User MMOJA anaweza kuunda Clients WENGI)
     *
     * fetch = FetchType.LAZY -> Hibernate HAITA-load User object
     *   nzima kila mara unapo-fetch Client. Ita-load tu ukiita
     *   client.getCreatedBy().getFullName() wazi kwenye code.
     *   Hii inaokoa database queries zisizo za lazima.
     *
     * @JoinColumn -> jina halisi la Foreign Key column kwenye jedwali
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private User createdBy;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
