package com.mentafinance;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Hii ndiyo "mlango" wa application yetu yote.
 *
 * @SpringBootApplication ni annotation "3-in-1" inayochanganya:
 *   1. @Configuration      -> class hii inaweza kuwa na Spring beans
 *   2. @EnableAutoConfiguration -> Spring Boot inajipangia mwenyewe
 *                                  vitu vingi (mf. embedded Tomcat,
 *                                  JPA config) kulingana na
 *                                  dependencies zilizo kwenye pom.xml
 *   3. @ComponentScan      -> Spring itatafuta @Component/@Service/
 *                             @Repository/@RestController zote ndani
 *                             ya package hii (com.mentafinance) na
 *                             sub-packages zake kiotomatiki
 *
 * @EnableScheduling -> Inawezesha methods zenye @Scheduled (kama
 *                       ServicePerformanceSchedulerService.runMonthlySnapshot())
 *                       kuendeshwa kiotomatiki na Spring kwa muda uliowekwa.
 */
@SpringBootApplication
@EnableScheduling
public class MentaFinanceApplication {

    public static void main(String[] args) {
        SpringApplication.run(MentaFinanceApplication.class, args);
    }

}