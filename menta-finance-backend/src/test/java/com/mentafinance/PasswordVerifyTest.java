package com.mentafinance;

import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordVerifyTest {

    @Test
    void verifyHash() {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String rawPassword = "ChangeMe123!";

        // BANDIKA HASH ULIYOIWEKA KWENYE DATABASE HAPA (kutoka Hatua ya 1)
               String storedHash = "$2a$10$FsqD32eCALJk.lwlLsSTQOwljWOABJqLtPS2PUOg6vw3f66s1RrR6";

        boolean matches = encoder.matches(rawPassword, storedHash);
        System.out.println("=================================================");
        System.out.println("Hash length: " + storedHash.length());
        System.out.println("MATCHES: " + matches);
        System.out.println("=================================================");
    }
}