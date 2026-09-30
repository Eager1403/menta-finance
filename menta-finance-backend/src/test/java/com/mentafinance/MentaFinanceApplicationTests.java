package com.mentafinance;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

/**
 * Test hii "rahisi" ina kazi moja tu: kuhakikisha Spring Application
 * Context inaweza kuanza (kuunda beans zote) bila kutupa error.
 * Ikiwa hii itashindwa (fail), inamaanisha kuna tatizo la msingi
 * kwenye configuration (mf. database haifikiki, bean haipatikani, n.k.)
 * kabla hata hatujafika kwenye logic ya business.
 */
@SpringBootTest
class MentaFinanceApplicationTests {

    @Test
    void contextLoads() {
        // Kwa makusudi tunaacha wazi - lengo ni kuona kama context
        // ya Spring inaanza kikamilifu wakati wa 'mvn test'
    }

}
