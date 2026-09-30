# Menta Finance — Backend

Spring Boot + PostgreSQL backend ya mfumo wa Menta Finance.

## Mahitaji
- Java 17+
- Maven
- PostgreSQL (database `menta_finance` na user `menta_user` tayari vimeundwa)

## Kuanzisha (Setup)

1. Fungua `src/main/resources/application.yml` na weka password sahihi ya database yako.
2. Kwenye terminal, kwenye folder ya project hii, endesha:

```bash
mvn clean install
mvn spring-boot:run
```

3. Flyway itatekeleza `V1__init_schema.sql` kiotomatiki na kuunda tables zote.
4. Application itaanza kwenye: `http://localhost:8080`
5. Swagger UI (kujaribu API): `http://localhost:8080/swagger-ui.html`

## Muundo wa Documentation
Angalia faili la `menta-finance-backend-design.md` (nje ya project hii) kwa maelezo kamili ya:
- ERD na permissions matrix
- Business rules (invoice calculation, income-invoice sync, edit windows)
- API endpoints zote

## Status ya sasa
- [x] Project skeleton (pom.xml, application.yml)
- [x] Database schema (Flyway V1)
- [ ] Entities (JPA)
- [ ] Security (JWT)
- [ ] Repositories
- [ ] Services
- [ ] Controllers
