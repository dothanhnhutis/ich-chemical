CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER DATABASE pgdb
    SET
        datestyle = 'ISO, DMY';

ALTER DATABASE pgdb
    SET
        timezone = 'UTC';

-- create files table
CREATE TABLE IF NOT EXISTS files
(
    id            TEXT           NOT NULL DEFAULT uuidv7()::text,
    original_name TEXT           NOT NULL, -- tên file người dùng upload
    mime_type     VARCHAR(255)   NOT NULL, -- loại file
    destination   TEXT           NOT NULL, -- đường dẫn ngắn đến file
    file_name     TEXT           NOT NULL, -- tên file
    path          TEXT           NOT NULL, -- đường dẫn đầy đủ đến file
    size          BIGINT         NOT NULL, -- kích thước file
    uploaded_by   TEXT           NOT NULL, -- upload bởi ai
    deleted_at    TIMESTAMPTZ(3),          -- xoá lúc nào
    -- category_id TEXT,
    created_at    TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT files_pkey PRIMARY KEY (id)
);

-- create audit_logs table
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


-- create user_avatars table
CREATE TABLE IF NOT EXISTS user_avatars
(
    file_id    TEXT           NOT NULL,
    user_id    TEXT           NOT NULL,
    width      INTEGER        NOT NULL,
    height     INTEGER        NOT NULL,
    is_primary BOOLEAN        NOT NULL DEFAULT FALSE, -- Hình đại diện
    deleted_at TIMESTAMPTZ(3),                        -- xoá lúc nào
    created_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT user_avatars_pkey PRIMARY KEY (file_id, user_id)
);

-- create index audit_logs table
CREATE INDEX idx_audit_logs_data_gin ON audit_logs USING GIN (old_data, new_data);

-- create index roles table
CREATE INDEX IF NOT EXISTS idx_roles_status ON roles (status) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_roles_name_status_active ON roles (name, status) WHERE deleted_at IS NULL;

-- create index users table
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email_unique ON users (email);

-- create index user_avatars_selected table
CREATE INDEX IF NOT EXISTS idx_user_avatars_selected ON user_avatars (is_primary) WHERE is_primary IS TRUE;

-- AddForeignKey role_permissions table
ALTER TABLE role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES permissions (id) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey user_roles table
ALTER TABLE user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE RESTRICT ON UPDATE CASCADE;

--- AddForeignKey user_avatars table
ALTER TABLE user_avatars
    ADD CONSTRAINT user_avatars_user_id_fkey FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE user_avatars
    ADD CONSTRAINT user_avatars_file_id_fkey FOREIGN KEY (file_id) REFERENCES files (id) ON DELETE CASCADE ON UPDATE CASCADE;



-- create fn_generic_audit_log trigger function
CREATE OR REPLACE FUNCTION fn_generic_audit_log()
    RETURNS TRIGGER AS
$$
DECLARE
    v_tx_id     TEXT;
    v_user_id   TEXT;
    v_record_id TEXT;
    v_data      JSONB;
BEGIN
    -- 1. Transaction ID (batch id)
    v_tx_id := current_setting('ich_app.current_transaction_id', true);
    IF v_tx_id = '' OR v_tx_id IS NULL THEN
        v_tx_id := uuidv7()::TEXT;
        PERFORM set_config('ich_app.current_transaction_id', v_tx_id, true);
    END IF;

    -- 2. User ID (từ app context)
    v_user_id := current_setting('ich_app.current_user_id', true);
    IF v_user_id = '' OR v_user_id IS NULL THEN
        v_user_id := 'SYSTEM';
        PERFORM set_config('ich_app.current_user_id', v_user_id, true);
    END IF;


    -- 3. Xác định giá trị cho v_record_id
    IF TG_OP = 'DELETE' THEN
        v_data := to_jsonb(OLD);
    ELSE
        v_data := to_jsonb(NEW);
    END IF;

    IF v_data ? 'id' THEN
        v_record_id := v_data ->> 'id';
    ELSEIF v_data ? 'role_id' AND v_data ? 'permission_id' THEN
        v_record_id := (v_data ->> 'role_id') || ':' || (v_data ->> 'permission_id');
    END IF;


    -- 3. Audit log
    INSERT INTO audit_logs (transaction_id,
                            table_name,
                            record_id,
                            action,
                            old_data,
                            new_data,
                            changed_by)
    VALUES (v_tx_id,
            TG_TABLE_NAME,
            v_record_id,
            TG_OP,
            CASE
                WHEN TG_OP <> 'INSERT' THEN to_jsonb(OLD)
                END,
            CASE
                WHEN TG_OP <> 'DELETE' THEN to_jsonb(NEW)
                END,
            v_user_id);

    -- AFTER trigger only
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- create trigger permissions
CREATE TRIGGER trg_permissions
    AFTER INSERT OR UPDATE OR DELETE
    ON permissions
    FOR EACH ROW
EXECUTE FUNCTION fn_generic_audit_log();

-- create trigger roles
CREATE TRIGGER trg_roles
    AFTER INSERT OR UPDATE OR DELETE
    ON roles
    FOR EACH ROW
EXECUTE FUNCTION fn_generic_audit_log();

-- create trigger role_permissions
CREATE TRIGGER trg_role_permissions
    AFTER INSERT OR UPDATE OR DELETE
    ON role_permissions
    FOR EACH ROW
EXECUTE FUNCTION fn_generic_audit_log();


--- func set_updated_at
CREATE OR REPLACE FUNCTION set_updated_at()
    RETURNS TRIGGER
    LANGUAGE plpgsql AS
$$
BEGIN
    IF NEW IS DISTINCT FROM OLD THEN
        NEW.updated_at := NOW();
    END IF;

    RETURN NEW;
END;
$$;

--- tạo trigger tự động cập nhật updated_at cho tất cả table nào có field updated_at
DO
$$
    DECLARE
        r        RECORD;
        trg_name TEXT;
    BEGIN
        FOR r IN
            SELECT table_schema, table_name
            FROM information_schema.columns
            WHERE column_name = 'updated_at'
              AND table_schema = 'public'
            LOOP
                trg_name := format('trg_updated_at_%s', r.table_name);

                EXECUTE format(
                        'DROP TRIGGER IF EXISTS %I ON %I.%I;',
                        trg_name,
                        r.table_schema,
                        r.table_name
                        );

                EXECUTE format(
                        'CREATE TRIGGER %I
                         BEFORE UPDATE ON %I.%I
                         FOR EACH ROW
                         EXECUTE FUNCTION set_updated_at();',
                        trg_name,
                        r.table_schema,
                        r.table_name
                        );
            END LOOP;
    END;
$$;