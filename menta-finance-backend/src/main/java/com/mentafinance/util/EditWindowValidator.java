package com.mentafinance.util;

import com.mentafinance.exception.BusinessRuleException;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

public class EditWindowValidator {

    private static final int EDIT_WINDOW_DAYS = 7;

    /**
     * Kama ilivyokubaliwa: Manager/SuperAdmin wanaweza edit/delete
     * Income/Expense TU ndani ya siku 7 tangu kuundwa kwake.
     */
    public static void checkWithinEditWindow(LocalDateTime createdAt) {
        long daysPassed = ChronoUnit.DAYS.between(createdAt, LocalDateTime.now());
        if (daysPassed > EDIT_WINDOW_DAYS) {
            throw new BusinessRuleException(
                "Muda wa kuhariri/kufuta rekodi hii umepita (siku " + EDIT_WINDOW_DAYS +
                "). Rekodi hii imeundwa siku " + daysPassed + " zilizopita."
            );
        }
    }
}