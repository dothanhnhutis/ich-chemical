-- DROP SCHEMA PUBLIC CASCADE;

-- CREATE SCHEMA PUBLIC;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER DATABASE pgdb
    SET
        datestyle = 'ISO, DMY';

ALTER DATABASE pgdb
    SET
        timezone = 'UTC';

--- timezone → ảnh hưởng đến giờ (lưu, hiển thị, convert). Có thể ép toàn DB về UTC.
--- datestyle → chỉ ảnh hưởng đến cách Postgres parse/hiển thị ngày (thứ tự ngày/tháng/năm). Nó không thay đổi dữ liệu bên trong.
-------
---- Các dạng datestyle hay gặp
----- ISO: chuẩn ISO-8601, hiển thị YYYY-MM-DD (rõ ràng, ít nhầm nhất).
----- MDY: tháng-ngày-năm (kiểu Mỹ).
----- DMY: ngày-tháng-năm (kiểu Châu Âu, VN quen dùng).
----- YMD: năm-tháng-ngày (ít khi xài vì ISO đã bao phủ).
-------
--- datestyle có thể có 1 hoặc 2 giá trị
---- 1 giá trị: chỉ định kiểu hiển thị (output format)
----- Ex: SET datestyle = 'ISO'; Hiển thị theo chuẩn ISO (YYYY-MM-DD)
---- 2 giá trị: giá trị đầu tiên là kiểu hiển thị, giá trị thứ hai là thứ tự khi parse input không rõ ràng.
----- Ex: SET datestyle = 'ISO, DMY';
----- ISO → in ra kiểu YYYY-MM-DD.
----- DMY → nếu bạn nhập '09-08-2025', PostgreSQL sẽ hiểu là 9 Aug 2025, không phải 8 Sep 2025.
---------------------------------

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
    status         VARCHAR(10)    NOT NULL DEFAULT 'ACTIVE',
    deactivated_at TIMESTAMPTZ(3), -- soft delete
    created_at     TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT users_pkey PRIMARY KEY (id)
);

--- create supplier table
CREATE TABLE IF NOT EXISTS suppliers
(
    id                   TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    company_name         VARCHAR(255)   NOT NULL, -- tên công ty Nhà cung cấp
    company_abbreviation VARCHAR(255)   NOT NULL, -- tên viết tắt Nhà cung cấp
    deactivated_at       TIMESTAMPTZ(3),          -- soft delete
    created_at           TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT suppliers_pkey PRIMARY KEY (id)
);

--- create chemical_suppliers
CREATE TABLE IF NOT EXISTS chemical_suppliers
(
    supplier_id TEXT           NOT NULL,
    chemical_id TEXT           NOT NULL,
    created_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_suppliers_pkey PRIMARY KEY (supplier_id, chemical_id)
);

--- create chemicals table
CREATE TABLE IF NOT EXISTS chemicals
(
    id                TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    trade_name        VARCHAR(255)   NOT NULL,               -- tên thương mại
    label_name        VARCHAR(255),                          -- tên nhãn phụ
    coa_name          VARCHAR(255)   NOT NULL,               -- tên COA
    manufacturer_name VARCHAR(255)   NOT NULL,               -- tên NSX
    cas_number        TEXT,                                  -- mã hoá chất
    origin_country    VARCHAR(50)    NOT NULL,               -- xuất xứ
    function          TEXT,                                  -- công dụng
    appearance        TEXT,                                  -- ngoại quang
    min_stock_level   DECIMAL(9, 3),                         -- tồn kho tôi thiểu gram
    deactivated_at    TIMESTAMPTZ(3),                        -- soft delete
    has_msds          BOOLEAN        NOT NULL DEFAULT FALSE, -- MSDS
    -- last_msds_update
    -- liên kết upload file
    created_at        TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemicals_pkey PRIMARY KEY (id)
);

--- create chemical_lots table
CREATE TABLE IF NOT EXISTS chemical_lots
(
    id                 TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    lot_number         VARCHAR(255)   NOT NULL,               -- mã lô nội bộ
    chemical_id        TEXT           NOT NULL,               -- mã nguyên liệu
    batch_number       VARCHAR(255)   NOT NULL,               -- mã batch nhà sản xuất
    date_precision     VARCHAR(20)    NOT NULL,               -- cho biết người dùng nhập HSD đến mức nào day|month|year
    manufactured_date  DATE           NOT NULL,               -- ngày SX
    expiry_date        DATE           NOT NULL,               -- HSD
    retest_date        DATE,                                  -- ngày retest
    status             VARCHAR(50),                           -- USABLE | NEED_RETEST | EXPIRED | QUARANTINED
    received_first_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(), -- ngày nhận lần đầu
    quantity_total     DECIMAL(15, 3) NOT NULL DEFAULT 0,     -- tổng đã nhập
    quantity_available DECIMAL(15, 3) NOT NULL DEFAULT 0,     -- tồn kho hiện tại
    received_last_at   TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(), -- ngày nhận cuối cùng
    deactivated_at     TIMESTAMPTZ(3),                        -- soft delete
    has_coa            BOOLEAN        NOT NULL DEFAULT FALSE, -- COA
    -- last_coa_upload_date
    -- liên kết upload file
    created_at         TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_lots_pkey PRIMARY KEY (id)
);

--- create chemical_orders table
CREATE TABLE IF NOT EXISTS chemical_orders
(
    id             TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    supplier_id    TEXT           NOT NULL,                   -- mã nhà cung cấp
    status         VARCHAR(50)    NOT NULL DEFAULT 'ORDERED', -- trạng thái đặt hàng ORDERED | PARTIALLY_RECEIVED | RECEIVED | CANCELLED
    note           TEXT           NOT NULL DEFAULT '',        -- ghi chú
    deactivated_at TIMESTAMPTZ(3),                            -- soft delete
    ordered_at     TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    created_at     TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_orders_pkey PRIMARY KEY (id)
);

--- create chemical_order_items table
CREATE TABLE IF NOT EXISTS chemical_order_items
(
    id               TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    order_id         TEXT           NOT NULL,             -- mã đơn hàng
    chemical_id      TEXT           NOT NULL,             -- mã nguyên liệu
    quantity_ordered DECIMAL(15, 3) NOT NULL,             -- số lượng đặt hàng gram
    unit_price       DECIMAL(18, 3) NOT NULL,             -- đơn giá VND
    total_price      DECIMAL(18, 3) GENERATED ALWAYS AS
        (ROUND(quantity_ordered * unit_price, 3)) STORED, -- thành tiền VND
    note             TEXT           NOT NULL DEFAULT '',  -- ghi chú
    created_at       TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_order_items_pkey PRIMARY KEY (id)
);

--- create chemical_receipts table
CREATE TABLE IF NOT EXISTS chemical_receipts
(
    id                TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    order_item_id     TEXT           NOT NULL,               -- mã phẩn tử của đơn hàng
    lot_id            TEXT           NOT NULL,               -- mã lot
    received_at       TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(), -- thời gian nhận
    quantity_received DECIMAL(15, 3) NOT NULL,               -- số lượng nhận gram
--     invoice_no        INT,                                   -- số hoá đơn
--     invoice_date      DATE,                                  -- ngày hoá đơn
    note              TEXT           NOT NULL DEFAULT '',    -- ghi chú
    created_at        TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_receipts_pkey PRIMARY KEY (id)
);


--- create index roles
CREATE INDEX IF NOT EXISTS idx_roles_active ON roles (status) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_roles_not_deleted ON roles (deleted_at);


--- create index users
CREATE INDEX IF NOT EXISTS idx_users_deactivated_at_null ON users (deactivated_at)
    WHERE deactivated_at IS NULL;
--- create unique index users
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email_active_unique ON users (email)
    WHERE deactivated_at IS NULL;



-- create check date_precision for chemical_lots table
ALTER TABLE chemical_lots
    ADD CONSTRAINT chk_date_precision_logic
        CHECK (
            (date_precision = 'day')
                OR (date_precision = 'month' AND extract(day from manufactured_date) = 1)
                OR (date_precision = 'year' AND extract(day from manufactured_date) = 1
                AND extract(month from manufactured_date) = 1)
            );

-- create check quantity_ordered and unit_price for chemical_order_items table
ALTER TABLE chemical_order_items
    ADD CONSTRAINT chk_positive_values CHECK ( quantity_ordered > 0 AND unit_price >= 0 );


--- AddForeignKey role_permissions
ALTER TABLE role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE RESTRICT ON UPDATE CASCADE;
--- AddForeignKey role_permissions
ALTER TABLE role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES permissions (id) ON DELETE RESTRICT ON UPDATE CASCADE;

--- AddForeignKey user_roles
ALTER TABLE user_roles
    ADD CONSTRAINT user_roles_user_id_users_id_fkey FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE;
--- AddForeignKey user_roles
ALTER TABLE user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE CASCADE ON UPDATE CASCADE;


--- AddForeignKey chemical_suppliers
ALTER TABLE chemical_suppliers
    ADD CONSTRAINT chemical_supliers_supplier_id_suppliers_id_fkey FOREIGN KEY (supplier_id) REFERENCES suppliers (id) ON DELETE CASCADE ON UPDATE CASCADE;
--- AddForeignKey chemical_suppliers
ALTER TABLE chemical_suppliers
    ADD CONSTRAINT chemical_supliers_chemical_id_chemicals_id_fkey FOREIGN KEY (chemical_id) REFERENCES chemicals (id) ON DELETE CASCADE ON UPDATE CASCADE;

--- AddForeignKey chemical_lots
ALTER TABLE chemical_lots
    ADD CONSTRAINT chemical_lots_chemical_id_chemicals_id_fkey FOREIGN KEY (chemical_id) REFERENCES chemicals (id) ON DELETE CASCADE ON UPDATE CASCADE;

--- AddForeignKey chemical_order_items
ALTER TABLE chemical_order_items
    ADD CONSTRAINT chemical_order_items_order_id_chemical_orders_id_fkey FOREIGN KEY (order_id) REFERENCES chemical_orders (id) ON DELETE CASCADE ON UPDATE CASCADE;
--- AddForeignKey chemical_order_items
ALTER TABLE chemical_order_items
    ADD CONSTRAINT chemical_order_items_chemical_id_chemicals_id_fkey FOREIGN KEY (chemical_id) REFERENCES chemicals (id) ON DELETE CASCADE ON UPDATE CASCADE;

--- AddForeignKey chemical_receipts
ALTER TABLE chemical_receipts
    ADD CONSTRAINT chemical_receipts_order_item_id_chemical_order_items_id_fkey FOREIGN KEY (order_item_id) REFERENCES chemical_order_items (id) ON DELETE CASCADE ON UPDATE CASCADE;
--- AddForeignKey chemical_receipts
ALTER TABLE chemical_receipts
    ADD CONSTRAINT chemical_receipts_lot_id_chemical_lots_id_fkey FOREIGN KEY (lot_id) REFERENCES chemical_lots (id) ON DELETE CASCADE ON UPDATE CASCADE;

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
