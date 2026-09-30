package com.mentafinance;

import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * HII SI TEST HALISI - ni "tool" ya muda ya kutengeneza BCrypt hash
 * kwa ajili ya SuperAdmin wa kwanza. Unaweza kuifuta baada ya kuitumia.
 */
public class PasswordHashGeneratorTest {

    @Test
    void generateHash() {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String rawPassword = "ChangeMe123!"; // BADILISHA hii kama unataka password tofauti
        String hash = encoder.encode(rawPassword);
        System.out.println("=================================================");
        System.out.println("PASSWORD: " + rawPassword);
        System.out.println("BCRYPT HASH: " + hash);
        System.out.println("=================================================");
    }
}