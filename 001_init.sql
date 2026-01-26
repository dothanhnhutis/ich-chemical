CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER DATABASE pgdb
    SET
        datestyle = 'ISO, DMY';

ALTER DATABASE pgdb
    SET
        timezone = 'UTC';

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

--- create permissions table
CREATE TABLE IF NOT EXISTS permissions
(
    id          TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    code        VARCHAR(100)   NOT NULL, -- vd: CHEMICAL_CREATE, PO_VIEW
    description TEXT           NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT permissions_pkey PRIMARY KEY (id),
    CONSTRAINT permissions_code_unique UNIQUE (code)
);

--- create role_permissions table
CREATE TABLE IF NOT EXISTS role_permissions
(
    role_id       TEXT           NOT NULL,
    permission_id TEXT           NOT NULL,
    created_at    TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id)
);

--- create roles table
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

--- create user_roles table
CREATE TABLE IF NOT EXISTS user_roles
(
    user_id    TEXT           NOT NULL,
    role_id    TEXT           NOT NULL,
    created_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id)
);

--- create users table
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

--- create user_avatars table
CREATE TABLE IF NOT EXISTS user_avatars
(
    file_id    TEXT           NOT NULL,
    user_id    TEXT           NOT NULL,
    width      INTEGER        NOT NULL,
    height     INTEGER        NOT NULL,
    is_primary BOOLEAN        NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT user_avatars_pkey PRIMARY KEY (file_id, user_id)
);

--- create supplier table
CREATE TABLE IF NOT EXISTS suppliers
(
    id                   TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    company_name         VARCHAR(255)   NOT NULL, -- tên công ty Nhà cung cấp
    company_abbreviation VARCHAR(255)   NOT NULL, -- tên viết tắt Nhà cung cấp
    deleted_at           TIMESTAMPTZ(3),          -- soft delete
    created_at           TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT suppliers_pkey PRIMARY KEY (id)
);

--- create chemical_suppliers table
CREATE TABLE IF NOT EXISTS chemical_suppliers
(
    supplier_id TEXT           NOT NULL,
    chemical_id TEXT           NOT NULL,
    created_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_suppliers_pkey PRIMARY KEY (supplier_id, chemical_id)
);

--- create chemical_manufacturers table
CREATE TABLE IF NOT EXISTS chemical_manufacturers
(
    id             TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    name           VARCHAR(255)   NOT NULL, -- tên NSX
    origin_country VARCHAR(50)    NOT NULL, -- xuất xứ
    deleted_at     TIMESTAMPTZ(3),          -- soft delete
    created_at     TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_manufacturers_pkey PRIMARY KEY (id)
);


--- create chemicals table
CREATE TABLE IF NOT EXISTS chemicals
(
    id              TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    manufacturer_id TEXT,                    -- mã NSX
    trade_name      VARCHAR(255)   NOT NULL, -- tên thương mại
    label_name      VARCHAR(255),            -- tên nhãn phụ
    coa_name        VARCHAR(255)   NOT NULL, -- tên COA
    cas_number      TEXT,                    -- mã hoá chất
    function        TEXT,                    -- công dụng
    appearance      TEXT,                    -- ngoại quang
    min_stock_level DECIMAL(9, 3),           -- tồn kho tôi thiểu gram
    deleted_at      TIMESTAMPTZ(3),          -- soft delete
    created_at      TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemicals_pkey PRIMARY KEY (id)
);

--- create user_avatars table
CREATE TABLE IF NOT EXISTS chemical_images
(
    file_id     TEXT           NOT NULL,
    chemical_id TEXT           NOT NULL,
    width       INTEGER        NOT NULL,
    height      INTEGER        NOT NULL,
    is_primary  BOOLEAN        NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_images_pkey PRIMARY KEY (file_id, chemical_id)
);

--- create user_avatars table
CREATE TABLE IF NOT EXISTS chemical_msds
(
    file_id     TEXT           NOT NULL,
    chemical_id TEXT           NOT NULL,
    created_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_msds_pkey PRIMARY KEY (file_id, chemical_id)
);


--- create chemical_lots table
CREATE TABLE IF NOT EXISTS chemical_lots
(
    id                 TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    lot_no             VARCHAR(255)   NOT NULL,                  -- mã lô nội bộ
    chemical_id        TEXT           NOT NULL,                  -- mã nguyên liệu
    batch_number       VARCHAR(255)   NOT NULL,                  -- mã batch nhà sản xuất / NCC
    date_precision     VARCHAR(20)    NOT NULL,                  -- cho biết người dùng nhập HSD đến mức nào day|month|year
    manufactured_date  DATE,                                     -- ngày SX
    expiry_date        DATE,                                     -- HSD
    retest_date        DATE,                                     -- ngày retest
    status             VARCHAR(50)    NOT NULL DEFAULT 'USABLE', -- USABLE | NEED_RETEST | EXPIRED | QUARANTINED
    note               TEXT           NOT NULL DEFAULT '',       -- ghi chú
    quantity_total     DECIMAL(15, 3) NOT NULL DEFAULT 0,        -- tổng đã nhập
    quantity_available DECIMAL(15, 3) NOT NULL DEFAULT 0,        -- tồn kho hiện tại
    deleted_at         TIMESTAMPTZ(3),                           -- soft delete

--     received_first_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),    -- ngày nhận lần đầu
--     received_last_at   TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),    -- ngày nhận cuối cùng

    created_at         TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_lots_pkey PRIMARY KEY (id),
    CONSTRAINT idx_chemical_lots_lot_no UNIQUE (lot_no)
);

--- create chemical_orders table
CREATE TABLE IF NOT EXISTS chemical_orders
(
    id          TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    supplier_id TEXT           NOT NULL,                 -- mã nhà cung cấp
    status      VARCHAR(50)    NOT NULL DEFAULT 'DRAFT', -- trạng thái đặt hàng DRAFT | ORDERED | PARTIALLY_RECEIVED | RECEIVED | CANCELLED
    note        TEXT           NOT NULL DEFAULT '',      -- ghi chú
--     ordered_by  TEXT           NOT NULL,                   -- mua hàng bởi ai
    ordered_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    canceled_at TIMESTAMPTZ(3),
    deleted_at  TIMESTAMPTZ(3),                          -- soft delete
    created_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_orders_pkey PRIMARY KEY (id)
);

--- create chemical_order_items table
CREATE TABLE IF NOT EXISTS chemical_order_items
(
    id                TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    order_id          TEXT           NOT NULL,            -- mã đơn hàng
    chemical_id       TEXT           NOT NULL,            -- mã nguyên liệu
    quantity_ordered  DECIMAL(15, 3) NOT NULL,            -- số lượng đặt hàng gram
    unit_price        DECIMAL(18, 3) NOT NULL,            -- đơn giá VND
    total_price       DECIMAL(18, 3) GENERATED ALWAYS AS
        (ROUND(quantity_ordered * unit_price, 3)) STORED, -- thành tiền VND
    note              TEXT           NOT NULL DEFAULT '', -- ghi chú
    quantity_received DECIMAL(18, 3) NOT NULL DEFAULT 0,  -- tổng đã nhận
    deleted_at        TIMESTAMPTZ(3),                     -- soft delete
    created_at        TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_order_items_pkey PRIMARY KEY (id)
);

--- create chemical_receipts table
CREATE TABLE IF NOT EXISTS chemical_receipts
(
    id          TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    order_id    TEXT,                                   -- mã đơn hàng
    status      VARCHAR(20)    NOT NULL DEFAULT 'DRAFT',-- DRAFT | POSTED | CANCELLED
    received_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),  -- thời gian nhận
--     received_by       TEXT           NOT NULL,               -- nhận bởi ai
    note        TEXT           NOT NULL DEFAULT '',     -- ghi chú
    deleted_at  TIMESTAMPTZ(3),                         -- soft delete
    created_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_receipts_pkey PRIMARY KEY (id)
);

--- create chemical_receipt_items table
CREATE TABLE IF NOT EXISTS chemical_receipt_items
(
    id                TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    receipt_id        TEXT           NOT NULL,
    order_item_id     TEXT,                               -- mã phẩn tử của đơn hàng
    chemical_id       TEXT           NOT NULL,            -- mã nguyên liệu
    lot_id            TEXT           NOT NULL,            -- mã lot
    quantity_received DECIMAL(15, 3) NOT NULL,            -- số lượng nhận gram
--     invoice_no        INT,                                   -- số hoá đơn
--     invoice_date      DATE,                                  -- ngày hoá đơn
    note              TEXT           NOT NULL DEFAULT '', -- ghi chú
    deleted_at        TIMESTAMPTZ(3),                     -- soft delete
    created_at        TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_receipt_items_pkey PRIMARY KEY (id)
);

--- create user_avatars table
CREATE TABLE IF NOT EXISTS chemical_receipt_images
(
    file_id             TEXT           NOT NULL,
    chemical_receipt_id TEXT           NOT NULL,
    width               INTEGER        NOT NULL,
    height              INTEGER        NOT NULL,
    created_at          TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_receipt_images_pkey PRIMARY KEY (file_id, chemical_receipt_id)
);


--- create chemical_receipts table
CREATE TABLE IF NOT EXISTS chemical_issues
(
    id          TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    status      VARCHAR(20)    NOT NULL DEFAULT 'DRAFT',-- DRAFT | POSTED | CANCELLED
    issue_type  VARCHAR(50)    NOT NULL,                -- PRODUCTION | SAMPLE | ADJUSTMENT | WASTE
    issued_at   TIMESTAMPTZ(3) NOT NULL DEFAULT now(),

--     issued_by       TEXT           NOT NULL,               -- xuất bởi ai
    note        TEXT           NOT NULL DEFAULT '',     -- ghi chú
    cancel_note TEXT           NOT NULL DEFAULT '',     -- ghi chú huỷ
    cancel_at   TIMESTAMPTZ(3),                         -- thời gian huỷ
    deleted_at  TIMESTAMPTZ(3),                         -- soft delete
    created_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_issues_pkey PRIMARY KEY (id)
);


CREATE TABLE IF NOT EXISTS chemical_issue_items
(
    id              TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    issue_id        TEXT           NOT NULL,
    chemical_id     TEXT           NOT NULL, -- snapshot để báo cáo
    lot_id          TEXT           NOT NULL, -- truy vết tồn kho chi tiết

    quantity_issued DECIMAL(15, 3) NOT NULL,

    note            TEXT           NOT NULL DEFAULT '',

    deleted_at      TIMESTAMPTZ(3),
    created_at      TIMESTAMPTZ(3) NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ(3) NOT NULL DEFAULT now(),

    CONSTRAINT chemical_issue_items_pkey PRIMARY KEY (id)
);

-- create index audit_logs table
CREATE INDEX idx_audit_logs_data_gin ON audit_logs USING GIN (old_data, new_data);

--- create index roles table
CREATE INDEX IF NOT EXISTS idx_roles_active ON roles (status) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_roles_not_deleted ON roles (deleted_at);

--- create index users table
CREATE INDEX IF NOT EXISTS idx_users_active ON users (status);
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email_active_unique ON users (email);

-- create check chemical_lots table
ALTER TABLE chemical_lots
    ADD CONSTRAINT chk_date_precision_logic
        CHECK (
            (date_precision = 'day')
                OR (date_precision = 'month' AND extract(day from manufactured_date) = 1)
                OR (date_precision = 'year' AND extract(day from manufactured_date) = 1
                AND extract(month from manufactured_date) = 1)
            );

--- AddForeignKey files table
ALTER TABLE files
    ADD CONSTRAINT files_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES users (id) ON DELETE RESTRICT ON UPDATE CASCADE;

--- AddForeignKey role_permissions table
ALTER TABLE role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES permissions (id) ON DELETE RESTRICT ON UPDATE CASCADE;

--- AddForeignKey user_avatars table
ALTER TABLE user_avatars
    ADD CONSTRAINT user_avatars_user_id_fkey FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE user_avatars
    ADD CONSTRAINT user_avatars_file_id_fkey FOREIGN KEY (file_id) REFERENCES files (id) ON DELETE CASCADE ON UPDATE CASCADE;

--- AddForeignKey user_roles table
ALTER TABLE user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE RESTRICT ON UPDATE CASCADE;

--- AddForeignKey chemical_suppliers table
ALTER TABLE chemical_suppliers
    ADD CONSTRAINT chemical_suppliers_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES suppliers (id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE chemical_suppliers
    ADD CONSTRAINT chemical_suppliers_chemical_id_fkey FOREIGN KEY (chemical_id) REFERENCES chemicals (id) ON DELETE RESTRICT ON UPDATE CASCADE;

--- AddForeignKey chemicals table
ALTER TABLE chemicals
    ADD CONSTRAINT chemicals_manufacturer_id_fkey FOREIGN KEY (manufacturer_id) REFERENCES chemical_manufacturers (id) ON DELETE RESTRICT ON UPDATE CASCADE;

--- AddForeignKey chemical_images table
ALTER TABLE chemical_images
    ADD CONSTRAINT chemical_images_file_id_fkey FOREIGN KEY (file_id) REFERENCES files (id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE chemical_images
    ADD CONSTRAINT chemical_images_chemical_id_fkey FOREIGN KEY (chemical_id) REFERENCES chemicals (id) ON DELETE RESTRICT ON UPDATE CASCADE;

--- AddForeignKey chemical_msds_files table
ALTER TABLE chemical_msds
    ADD CONSTRAINT chemical_msds_file_id_fkey FOREIGN KEY (file_id) REFERENCES files (id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE chemical_msds
    ADD CONSTRAINT chemical_msds_chemical_id_fkey FOREIGN KEY (chemical_id) REFERENCES chemicals (id) ON DELETE RESTRICT ON UPDATE CASCADE;


--- AddForeignKey chemical_lots table
ALTER TABLE chemical_lots
    ADD CONSTRAINT chemical_lots_chemical_id_fkey FOREIGN KEY (chemical_id) REFERENCES chemicals (id) ON DELETE CASCADE ON UPDATE CASCADE;

--- AddForeignKey chemical_order_items
ALTER TABLE chemical_order_items
    ADD CONSTRAINT chemical_order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES chemical_orders (id) ON DELETE RESTRICT ON UPDATE CASCADE;

--- AddForeignKey chemical_receipts
ALTER TABLE chemical_receipts
    ADD CONSTRAINT chemical_receipts_order_id_fkey FOREIGN KEY (order_id) REFERENCES chemical_orders (id) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey chemical_receipt_items table
ALTER TABLE chemical_receipt_items
    ADD CONSTRAINT chemical_receipt_items_receipt_id_fkey FOREIGN KEY (receipt_id) REFERENCES chemical_receipts (id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE chemical_receipt_items
    ADD CONSTRAINT chemical_receipt_items_chemical_id_fkey FOREIGN KEY (chemical_id) REFERENCES chemicals (id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE chemical_receipt_items
    ADD CONSTRAINT chemical_receipt_items_lot_id_fkey FOREIGN KEY (lot_id) REFERENCES chemical_lots (id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE chemical_receipt_items
    ADD CONSTRAINT chemical_receipt_items_order_item_id_fkey FOREIGN KEY (order_item_id) REFERENCES chemical_order_items (id) ON DELETE RESTRICT ON UPDATE CASCADE;


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
