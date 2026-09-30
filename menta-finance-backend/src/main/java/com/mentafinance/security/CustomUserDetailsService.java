package com.mentafinance.security;

import com.mentafinance.entity.User;
import com.mentafinance.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

/**
 * @RequiredArgsConstructor (Lombok) -> inatengeneza constructor
 *   kiotomatiki kwa fields zote za "final" (hapa: userRepository).
 *   Hii ndiyo "Constructor Injection" - njia inayopendekezwa na Spring
 *   kuliko @Autowired field injection, kwa sababu inafanya dependencies
 *   ziwe wazi na inarahisisha testing (unaweza kuweka mock kwa urahisi).
 */
@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Email haipo: " + email));
        return new CustomUserDetails(user);
    }
}