package com.mentafinance.repository;

import com.mentafinance.entity.User;
import com.mentafinance.entity.enums.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

/**
 * JpaRepository<User, Long> inatupa BURE (bila kuandika chochote):
 *   save(), findById(), findAll(), deleteById(), count(), n.k.
 *
 * Optional<User> (badala ya User moja kwa moja) -> inatulazimisha
 *   ku-handle "ikiwa hakuna user mwenye email hii" wazi kwenye code
 *   (mf. .orElseThrow(...)), badala ya kupata NullPointerException
 *   ya kushtukiza baadaye kwenye code.
 */
public interface UserRepository extends JpaRepository<User, Long> {

    // Itatumika kwenye LOGIN: kutafuta user kwa email aliyoingiza
    Optional<User> findByEmail(String email);

    // Kuangalia kama email tayari ipo (kabla ya kuunda user mpya - kuepuka duplicate)
    boolean existsByEmail(String email);

    // Kwa Reports/Team management: kuona SUPERADMIN/MANAGER wote kwa mfano
    List<User> findByRole(UserRole role);

    List<User> findByActiveTrue();
}
