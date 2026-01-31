

-- create supplier table
CREATE TABLE IF NOT EXISTS suppliers
(
    id                   TEXT           NOT NULL DEFAULT uuidv7()::TEXT,
    company_name         VARCHAR(255)   NOT NULL, -- tên công ty Nhà cung cấp
    company_abbreviation VARCHAR(255)   NOT NULL, -- tên viết tắt Nhà cung cấp
    deleted_at           TIMESTAMPTZ(3),          -- soft delete
    created_at           TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT suppliers_pkey PRIMARY KEY (id),
    CONSTRAINT suppliers_company_abbreviation_unique UNIQUE (company_abbreviation)
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


-- create chemical_suppliers table
CREATE TABLE IF NOT EXISTS chemical_suppliers
(
    supplier_id TEXT           NOT NULL,
    chemical_id TEXT           NOT NULL,
    created_at  TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
    CONSTRAINT chemical_suppliers_pkey PRIMARY KEY (supplier_id, chemical_id)
);