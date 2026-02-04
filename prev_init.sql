-- create supplier table
CREATE TABLE IF NOT EXISTS suppliers
(
    id               TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    name             VARCHAR(255)   NOT NULL,            -- tên công ty Nhà cung cấp
    abbreviated_name VARCHAR(255)   NOT NULL,            -- tên viết tắt Nhà cung cấp
    address          VARCHAR(255)   NOT NULL DEFAULT '', -- Địa chỉ
    phone_number     VARCHAR(50)    NOT NULL DEFAULT '', -- Số điện thoại
    deleted_at       TIMESTAMPTZ(3),                     -- soft delete
    created_at       TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT suppliers_pkey PRIMARY KEY (id),
    CONSTRAINT suppliers_company_abbreviation_unique UNIQUE (company_abbreviation)
);

--- create chemical_manufacturers table
CREATE TABLE IF NOT EXISTS chemical_manufacturers
(
    id             TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    name           VARCHAR(255)   NOT NULL,            -- tên NSX
    origin_country VARCHAR(50)    NOT NULL,            -- xuất xứ
    address        VARCHAR(255)   NOT NULL DEFAULT '', -- Địa chỉ
    phone_number   VARCHAR(50)    NOT NULL DEFAULT '', -- Số điện thoại
    deleted_at     TIMESTAMPTZ(3),                     -- soft delete
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

-- create chemical_suppliers table
CREATE TABLE IF NOT EXISTS chemical_suppliers
(
    supplier_id TEXT           NOT NULL,
    chemical_id TEXT           NOT NULL,
    created_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_suppliers_pkey PRIMARY KEY (supplier_id, chemical_id)
);

-- create lot_sequences table
CREATE TABLE IF NOT EXISTS lot_sequences
(
    prefix_date DATE NOT NULL,     -- Lưu ngày (ví dụ: 2026-01-04)
    last_val    INTEGER DEFAULT 0, -- Số thứ tự cuối cùng trong ngày đó
    CONSTRAINT lot_sequences_pkey PRIMARY KEY (prefix_date)
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
    quantity_total     DECIMAL(15, 3) NOT NULL DEFAULT 0,        -- tổng đã nhập của lô
    quantity_available DECIMAL(15, 3) NOT NULL DEFAULT 0,        -- tồn kho hiện tại của lô
    deleted_at         TIMESTAMPTZ(3),                           -- soft delete

--     received_first_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),    -- ngày nhận lần đầu
--     received_last_at   TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),    -- ngày nhận cuối cùng

    created_at         TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_lots_pkey PRIMARY KEY (id),
    CONSTRAINT idx_chemical_lots_lot_no UNIQUE (lot_no)
);

-- Addforeignkey chemicals
ALTER TABLE chemicals
    ADD CONSTRAINT chemicals_manufacturer_id_fkey FOREIGN KEY (manufacturer_id) REFERENCES chemical_manufacturers (id) ON DELETE RESTRICT ON UPDATE CASCADE;

-- Addforeignkey chemical_suppliers
ALTER TABLE chemical_suppliers
 ADD CONSTRAINT chemical_suppliers_chemical_id_fkey FOREIGN KEY (chemical_id) REFERENCES chemicals (id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE chemical_suppliers
 ADD CONSTRAINT chemical_suppliers_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES suppliers (id) ON DELETE CASCADE ON UPDATE CASCADE;




