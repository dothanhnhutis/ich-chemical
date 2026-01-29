CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER DATABASE pgdb
    SET
        datestyle = 'ISO, DMY';

ALTER DATABASE pgdb
    SET
        timezone = 'UTC';


CREATE TABLE IF NOT EXISTS audit_logs
(
    id             TEXT NOT NULL  DEFAULT uuidv7()::text,
    table_name     TEXT NOT NULL,               -- Thông tin bảng dữ liệu
    record_id      TEXT NOT NULL,               -- Thông tin dòng dữ liệu
    action         TEXT NOT NULL,               -- INSERT, UPDATE, DELETE
    old_data       JSONB,                       -- Dữ liệu trước khi sửa
    new_data       JSONB,                       -- Dữ liệu sau khi sửa
    changed_by     TEXT NOT NULL,               -- ID người thực hiện
    transaction_id TEXT,                        -- ID transaction
    changed_at     TIMESTAMPTZ(3) DEFAULT NOW() -- Thời gian thực hiện
);


-- create permissions table
CREATE TABLE IF NOT EXISTS permissions
(
    id          TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    code        VARCHAR(100)   NOT NULL, -- vd: CHEMICAL_CREATE, PO_VIEW
    description TEXT           NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT permissions_pkey PRIMARY KEY (id),
    CONSTRAINT permissions_code_unique UNIQUE (code)
);

-- create role_permissions table
CREATE TABLE IF NOT EXISTS role_permissions
(
    role_id       TEXT           NOT NULL,
    permission_id TEXT           NOT NULL,
    created_at    TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id)
);

-- create roles table
CREATE TABLE IF NOT EXISTS roles
(
    id             TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    name           VARCHAR(255)   NOT NULL,
    description    TEXT           NOT NULL DEFAULT '',
    status         VARCHAR(10)    NOT NULL DEFAULT 'ACTIVE', -- ACTIVE | DISABLED
    deactivated_at TIMESTAMPTZ(3),                           -- vô hiệu hoá lúc nào
    deleted_at     TIMESTAMPTZ(3),                           -- xoá mềm
    can_delete     BOOLEAN        NOT NULL DEFAULT TRUE,
    can_update     BOOLEAN        NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT roles_pkey PRIMARY KEY (id)
);

-- create user_roles table
CREATE TABLE IF NOT EXISTS user_roles
(
    user_id    TEXT           NOT NULL,
    role_id    TEXT           NOT NULL,
    created_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id)
);

-- create users table
CREATE TABLE IF NOT EXISTS users
(
    id             TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    email          VARCHAR(255)   NOT NULL,
    password_hash  TEXT           NOT NULL,
    username       VARCHAR(100)   NOT NULL,
    status         VARCHAR(10)    NOT NULL DEFAULT 'ACTIVE', -- ACTIVE | DISABLED
    deactivated_at TIMESTAMPTZ(3),                           -- vô hiệu hoá lúc nào
    created_at     TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT users_pkey PRIMARY KEY (id)
);


-- create index audit_logs table
CREATE INDEX idx_audit_logs_data_gin ON audit_logs USING GIN (old_data, new_data);

--- create index roles table
CREATE INDEX IF NOT EXISTS idx_roles_status ON roles (status) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_roles_name_status_active ON roles (name, status) WHERE deleted_at IS NULL;


--- create index users table
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email_unique ON users (email);


--- AddForeignKey role_permissions table
ALTER TABLE role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES permissions (id) ON DELETE RESTRICT ON UPDATE CASCADE;


--- AddForeignKey user_roles table
ALTER TABLE user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE RESTRICT ON UPDATE CASCADE;


