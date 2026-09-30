package com.mentafinance.entity.enums;

/**
 * Roles tatu za mfumo. Majina haya (SUPERADMIN, MANAGER, STAFF)
 * LAZIMA yaendane HASA (herufi kubwa/ndogo) na values zilizoko
 * kwenye PostgreSQL enum type "user_role" (angalia V1__init_schema.sql).
 * Hibernate italinganisha majina haya moja kwa moja na database.
 */
public enum UserRole {
    SUPERADMIN,
    MANAGER,
    STAFF
}
