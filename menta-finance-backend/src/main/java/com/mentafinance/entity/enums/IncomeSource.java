package com.mentafinance.entity.enums;

/**
 * MANUAL          = mtu ameongeza Income moja kwa moja (Add Income screen)
 * INVOICE_PAYMENT = Income hii ilitengenezwa KIOTOMATIKO wakati
 *                   InvoicePayment ilipoongezwa (angalia
 *                   InvoiceService.recordPayment() baadaye).
 *                   Income yenye source hii HAIWEZI kuhaririwa
 *                   moja kwa moja kwenye Income screen.
 */
public enum IncomeSource {
    MANUAL,
    INVOICE_PAYMENT
}
