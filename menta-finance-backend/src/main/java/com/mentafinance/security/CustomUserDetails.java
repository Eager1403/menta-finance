package com.mentafinance.security;

import com.mentafinance.entity.User;
import com.mentafinance.entity.enums.UserRole;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

public class CustomUserDetails implements UserDetails {

    private final User user;

    public CustomUserDetails(User user) {
        this.user = user;
    }

    public Long getUserId() {
        return user.getId();
    }

    public UserRole getRole() {
        return user.getRole();
    }

    public String getFullName() {
        return user.getFullName();
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // "ROLE_" prefix ni LAZIMA - ndiyo namna Spring Security's
        // hasRole("MANAGER") inavyotafuta authority "ROLE_MANAGER"
        return List.of(new SimpleGrantedAuthority("ROLE_" + user.getRole().name()));
    }

    @Override
    public String getPassword() {
        return user.getPasswordHash();
    }

    @Override
    public String getUsername() {
        return user.getEmail(); // tunatumia email kama "username" ya login
    }

    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return true; }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() {
        return user.getActive(); // user asiye-active hawezi login
    }
}