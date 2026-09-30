package com.mentafinance.exception;

/**
 * Kwa makosa ya "sheria za biashara" (mf. "CLIENT project lazima
 * iwe na client_id") - tofauti na ResourceNotFoundException (404),
 * hii ni "umeomba kitu kisicho sahihi" (400 Bad Request).
 */
public class BusinessRuleException extends RuntimeException {
    public BusinessRuleException(String message) {
        super(message);
    }
}