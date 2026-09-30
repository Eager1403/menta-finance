package com.mentafinance.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public class SecurityUtils {

    /**
     * Kila Controller/Service itakayohitaji kujua "nani amelogin"
     * (kwa ajili ya createdBy, recordedBy, n.k.) itaita method hii
     * badala ya kupitisha userId kama parameter kila mahali.
     */
    public static CustomUserDetails getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof CustomUserDetails)) {
            throw new IllegalStateException("Hakuna mtumiaji aliye-login kwenye context hii");
        }
        return (CustomUserDetails) auth.getPrincipal();
    }

    public static Long getCurrentUserId() {
        return getCurrentUser().getUserId();
    }
}