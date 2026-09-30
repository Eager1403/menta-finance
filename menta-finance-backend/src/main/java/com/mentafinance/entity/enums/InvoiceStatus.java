package com.mentafinance.entity.enums;

/**
 * DRAFT     = invoice imeundwa lakini haijatumwa kwa client
 * SENT      = imetumwa, bado hakuna malipo (amount_paid = 0)
 * PARTIAL   = kuna malipo kiasi lakini balance_due > 0
 * PAID      = imelipwa kikamilifu (amount_paid >= total)
 * OVERDUE   = due_date imepita bila kulipwa kikamilifu
 * CANCELLED = imefutwa/kughairiwa
 *
 * Status hii itasasishwa KIOTOMATIKO na Service layer (si mtu
 * kuichagua manually kila wakati) - tutaiona hii kwenye
 * InvoiceService baadaye.
 */
public enum InvoiceStatus {
    DRAFT,
    SENT,
    PARTIAL,
    PAID,
    OVERDUE,
    CANCELLED
}
