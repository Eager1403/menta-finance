package com.mentafinance.entity;

import com.mentafinance.entity.enums.UserRole;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;

import java.time.LocalDateTime;

/**
 * Inaendana na jedwali "users" (login accounts - SUPERADMIN/MANAGER/STAFF).
 *
 * ANNOTATIONS MUHIMU (maelezo ya jumla, yatatumika kwenye entities
 * nyingine zote pia bila kurudia maelezo):
 *
 * @Entity            -> Inaambia Hibernate "hii class ni jedwali la DB"
 * @Table(name=...)   -> Jina halisi la jedwali (muhimu kama jina la
 *                       class na jedwali havifanani, kama ilivyo kwa
 *                       ServiceOffering -> "services")
 * @Id                -> Hii field ndiyo Primary Key
 * @GeneratedValue(strategy = IDENTITY) -> PostgreSQL yenyewe ndiyo
 *                       inayotengeneza namba (BIGSERIAL), Java
 *                       haitengenezi ID - inasoma tu iliyorudishwa
 *
 * LOMBOK (zinapunguza boilerplate code - getters/setters/constructors):
 * @Getter/@Setter    -> Inatengeneza getX()/setX() kiotomatiki
 * @NoArgsConstructor -> Constructor tupu (JPA INAHITAJI hii lazima iwepo)
 * @AllArgsConstructor-> Constructor yenye parameters zote
 * @Builder           -> Inaruhusu kuunda object kwa mtindo:
 *                       User.builder().fullName("...").email("...").build()
 */
@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "full_name", nullable = false, length = 150)
    private String fullName;

    @Column(nullable = false, unique = true, length = 150)
    private String email;

    /**
     * Hii itahifadhi BCrypt hash, SIYO password ya wazi (plain text).
     * Tutaifundisha jinsi ya kutengeneza hash kwenye Hatua ya Security.
     */
    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    /**
     * @Enumerated(EnumType.STRING) -> Hibernate itatuma jina la enum
     *   (mf. "MANAGER") badala ya namba yake ya order (0,1,2..) - hii
     *   ni muhimu sana, bila STRING, ukiongeza enum value mpya katikati
     *   baadaye, data zote za nyuma zitachanganyikiwa.
     *
     * @JdbcTypeCode(SqlTypes.NAMED_ENUM) -> Hii inamwambia Hibernate
     *   "column hii ni PostgreSQL NATIVE ENUM TYPE (user_role), siyo
     *   VARCHAR ya kawaida". Bila hii annotation, utapata error:
     *   "column is of type user_role but expression is of type character varying"
     *
     * columnDefinition -> jina halisi la enum type kwenye PostgreSQL
     */
    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(columnDefinition = "user_role", nullable = false)
    private UserRole role;

    @Column(nullable = false)
    @Builder.Default
    private Boolean active = true;

    /**
     * @CreationTimestamp -> Hibernate INAWEKA muda kiotomatiki mara
     *   moja tu, wakati record inapoundwa (INSERT). Hatuhitaji
     *   kuandika "user.setCreatedAt(LocalDateTime.now())" popote
     *   kwenye code yetu - itatokea yenyewe.
     */
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /**
     * @UpdateTimestamp -> Hibernate inasasisha hii KIOTOMATIKO kila
     *   mara record inapo-UPDATE (si tu wakati wa kuundwa).
     */
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
