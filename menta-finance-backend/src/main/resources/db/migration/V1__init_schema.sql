-- =====================================================================
-- MENTA FINANCE - INITIAL SCHEMA (V1)
-- Flyway itatekeleza script hii MARA MOJA TU, wakati project
-- inapoanzishwa kwa mara ya kwanza dhidi ya database tupu.
-- =====================================================================

-- ================= ENUMS =================
-- Tunatumia PostgreSQL ENUM types badala ya VARCHAR + CHECK constraint
-- kwa sababu: (1) inazuia data isiyo sahihi kuingia (mf. "SUPERADMN"
-- typo haiwezi kuingia), (2) inachukua nafasi ndogo zaidi kwenye disk,
-- (3) ni wazi zaidi kusoma kwenye schema.
CREATE TYPE user_role AS ENUM ('SUPERADMIN','MANAGER','STAFF');
CREATE TYPE project_type_enum AS ENUM ('CLIENT','INTERNAL');
CREATE TYPE project_status_enum AS ENUM ('ONGOING','COMPLETED','CANCELLED');
CREATE TYPE invoice_status_enum AS ENUM ('DRAFT','SENT','PARTIAL','PAID','OVERDUE','CANCELLED');
CREATE TYPE income_source_enum AS ENUM ('MANUAL','INVOICE_PAYMENT');

-- ================= USERS =================
-- Hii ndiyo jedwali la login accounts (SUPERADMIN/MANAGER/STAFF pekee)
CREATE TABLE users (
    id              BIGSERIAL PRIMARY KEY,
    full_name       VARCHAR(150) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    role            user_role NOT NULL,
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP NOT NULL DEFAULT now()
);

-- ================= CLIENTS =================
CREATE TABLE clients (
    id              BIGSERIAL PRIMARY KEY,
    name            VARCHAR(150) NOT NULL,
    phone           VARCHAR(30),
    email           VARCHAR(150),
    address         TEXT,
    created_by      BIGINT REFERENCES users(id),
    created_at      TIMESTAMP NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP NOT NULL DEFAULT now()
);

-- ================= SERVICES =================
CREATE TABLE services (
    id              BIGSERIAL PRIMARY KEY,
    name            VARCHAR(150) NOT NULL UNIQUE,
    description     TEXT,
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_by      BIGINT REFERENCES users(id),
    created_at      TIMESTAMP NOT NULL DEFAULT now()
);

-- ================= PROJECTS =================
CREATE TABLE projects (
    id              BIGSERIAL PRIMARY KEY,
    name            VARCHAR(200) NOT NULL,
    client_id       BIGINT REFERENCES clients(id),
    service_id      BIGINT REFERENCES services(id),
    project_type    project_type_enum NOT NULL DEFAULT 'CLIENT',
    project_value   NUMERIC(15,2) NOT NULL DEFAULT 0,
    status          project_status_enum NOT NULL DEFAULT 'ONGOING',
    start_date      DATE,
    end_date        DATE,
    created_by      BIGINT REFERENCES users(id),
    created_at      TIMESTAMP NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP NOT NULL DEFAULT now(),
    -- Project ya CLIENT type LAZIMA iwe na client_id;
    -- Project ya INTERNAL type (mf. "Company Overhead") haihitaji client
    CONSTRAINT chk_client_required
        CHECK (project_type = 'INTERNAL' OR client_id IS NOT NULL)
);

-- ================= INVOICES =================
CREATE TABLE invoices (
    id              BIGSERIAL PRIMARY KEY,
    invoice_number  VARCHAR(30) NOT NULL UNIQUE,
    client_id       BIGINT NOT NULL REFERENCES clients(id),
    project_id      BIGINT REFERENCES projects(id),
    issue_date      DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date        DATE,
    subtotal        NUMERIC(15,2) NOT NULL DEFAULT 0,
    discount        NUMERIC(15,2) NOT NULL DEFAULT 0,
    tax_percent     NUMERIC(5,2) NOT NULL DEFAULT 0,
    tax_amount      NUMERIC(15,2) NOT NULL DEFAULT 0,
    total           NUMERIC(15,2) NOT NULL DEFAULT 0,
    amount_paid     NUMERIC(15,2) NOT NULL DEFAULT 0,
    -- GENERATED ALWAYS AS ... STORED: PostgreSQL inahesabu hii yenyewe
    -- kila mara amount_paid au total inapobadilika - hatuwezi
    -- "kusahau" kui-update kwa mkono na kupata namba isiyo sahihi.
    balance_due     NUMERIC(15,2) GENERATED ALWAYS AS (total - amount_paid) STORED,
    status          invoice_status_enum NOT NULL DEFAULT 'DRAFT',
    notes           TEXT,
    created_by      BIGINT REFERENCES users(id),
    created_at      TIMESTAMP NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE invoice_items (
    id              BIGSERIAL PRIMARY KEY,
    invoice_id      BIGINT NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    description     VARCHAR(255) NOT NULL,
    qty             NUMERIC(10,2) NOT NULL DEFAULT 1,
    unit_price      NUMERIC(15,2) NOT NULL,
    amount          NUMERIC(15,2) GENERATED ALWAYS AS (qty * unit_price) STORED
);

CREATE TABLE invoice_payments (
    id              BIGSERIAL PRIMARY KEY,
    invoice_id      BIGINT NOT NULL REFERENCES invoices(id),
    amount          NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    payment_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_method  VARCHAR(50),
    reference_no    VARCHAR(100),
    notes           TEXT,
    recorded_by     BIGINT REFERENCES users(id),
    created_at      TIMESTAMP NOT NULL DEFAULT now()
);

-- ================= INCOME / EXPENSES =================
CREATE TABLE income (
    id                  BIGSERIAL PRIMARY KEY,
    project_id          BIGINT NOT NULL REFERENCES projects(id),
    description         VARCHAR(255),
    amount              NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    income_date         DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_method      VARCHAR(50),
    -- source_type inatuambia kama hii income ilitoka wapi:
    -- MANUAL = mtu ameiongeza mwenyewe kwenye Income screen
    -- INVOICE_PAYMENT = ilitengenezwa kiotomatiki wakati mtu
    --                   aliporekodi malipo ya invoice
    source_type         income_source_enum NOT NULL DEFAULT 'MANUAL',
    invoice_payment_id  BIGINT REFERENCES invoice_payments(id),
    recorded_by         BIGINT REFERENCES users(id),
    created_at          TIMESTAMP NOT NULL DEFAULT now(),
    updated_at          TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE expenses (
    id              BIGSERIAL PRIMARY KEY,
    project_id      BIGINT NOT NULL REFERENCES projects(id),
    description     VARCHAR(255),
    amount          NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    expense_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    category        VARCHAR(100),
    recorded_by     BIGINT REFERENCES users(id),
    created_at      TIMESTAMP NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP NOT NULL DEFAULT now()
);

-- ================= TEAM (siyo login accounts - orodha tu) =================
CREATE TABLE team_members (
    id              BIGSERIAL PRIMARY KEY,
    full_name       VARCHAR(150) NOT NULL,
    position        VARCHAR(100),
    phone           VARCHAR(30),
    email           VARCHAR(150),
    joined_date     DATE,
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    added_by        BIGINT REFERENCES users(id),
    created_at      TIMESTAMP NOT NULL DEFAULT now(),
    updated_at      TIMESTAMP NOT NULL DEFAULT now()
);

-- ================= SERVICE PERFORMANCE (monthly snapshot) =================
CREATE TABLE service_performance_monthly (
    id                  BIGSERIAL PRIMARY KEY,
    service_id          BIGINT NOT NULL REFERENCES services(id),
    year_month          DATE NOT NULL,
    total_income        NUMERIC(15,2) NOT NULL DEFAULT 0,
    total_expense       NUMERIC(15,2) NOT NULL DEFAULT 0,
    net_profit          NUMERIC(15,2) NOT NULL DEFAULT 0,
    project_count       INT NOT NULL DEFAULT 0,
    client_count        INT NOT NULL DEFAULT 0,
    avg_project_value   NUMERIC(15,2) NOT NULL DEFAULT 0,
    generated_at        TIMESTAMP NOT NULL DEFAULT now(),
    UNIQUE (service_id, year_month)
);

-- ================= AUDIT LOG =================
CREATE TABLE audit_log (
    id              BIGSERIAL PRIMARY KEY,
    entity_name     VARCHAR(50) NOT NULL,
    entity_id       BIGINT NOT NULL,
    action          VARCHAR(20) NOT NULL,
    performed_by    BIGINT REFERENCES users(id),
    old_value       JSONB,
    new_value       JSONB,
    performed_at    TIMESTAMP NOT NULL DEFAULT now()
);

-- ================= INDEXES =================
-- Hizi zinaharakisha queries za kawaida (mf. "onyesha income zote za
-- project fulani, zilizopangwa kwa tarehe") - bila index, PostgreSQL
-- inasoma jedwali zima (full table scan) kila query, jambo linalokuwa
-- polepole sana data zikiongezeka.
CREATE INDEX idx_income_project_date ON income(project_id, income_date);
CREATE INDEX idx_expenses_project_date ON expenses(project_id, expense_date);
CREATE INDEX idx_invoices_client ON invoices(client_id);
CREATE INDEX idx_invoice_items_invoice ON invoice_items(invoice_id);
CREATE INDEX idx_invoice_payments_invoice ON invoice_payments(invoice_id);
CREATE INDEX idx_perf_service_month ON service_performance_monthly(service_id, year_month);

-- ================= SEED DATA (data ya awali muhimu) =================

-- Services zilizoonekana kwenye mfumo tayari
INSERT INTO services (name) VALUES
 ('Graphics Design'),
 ('Photoshooting'),
 ('Apartment Branding'),
 ('Video Production'),
 ('Wedding Services');

-- Project maalum ya "ndani" kwa gharama za kampuni zisizo za mteja
-- (mf. chai, matengenezo ya vifaa) - inatumika badala ya kuacha
-- project_id ikiwa NULL kwenye expenses/income
INSERT INTO projects (name, project_type, project_value, status)
VALUES ('Company Overhead', 'INTERNAL', 0, 'ONGOING');

-- MUHIMU: Seed ya SuperAdmin wa kwanza ITAONGEZWA kwenye V2__seed_superadmin.sql
-- baada ya kutengeneza BCrypt hash HALISI kwenye Hatua ya Security (hatuwezi
-- kuandika hash "ya kubahatisha" hapa kwa sababu password haitafanya kazi
-- kama hash haikutengenezwa na algorithm/version sahihi).
