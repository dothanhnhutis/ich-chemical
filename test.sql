INSERT INTO suppliers (id, company_name, company_abbreviation)
VALUES ('019c07b5-1336-7ed6-9f0d-1d463daaf33f', 'CÔNG TY TNHH IWASE COSFA VIỆT NAM', 'Iwase Cosfa VN'),
       ('019c07b5-133d-799a-8bbe-aa8aa79797fe', 'CÔNG TY TNHH KHANG NGOC', 'Khang Ngọc'),
       ('019c07b5-133d-7a2c-b69e-ba5ea7e85bcb', 'CÔNG TY TNHH INTRIE COSMETIC', 'Intrie Cosmetic')
RETURNING *;


INSERT INTO chemical_manufacturers (id, name, origin_country)
VALUES ('019c07bb-018d-7a01-a5d9-10a3ec08ca12', 'KATAKURA & CO-OP AGRI CORP', 'Nhật Bản'),
       ('019c07bb-0190-779b-85fb-88c2d686d4ff', 'Sinoway Industrial Co.,Ltd', 'Trung Quốc'),
       ('019c07bb-0190-780d-9368-fb0fea8229cc', 'BASF SE', 'Đức'),
       ('019c07bb-0190-782e-ba1f-fa0d00604e8c', 'CoSeedBioPharm Co., Ltd', 'Hàn Quốc'),
       ('019c07bb-0190-784b-9475-a6929ad5de8b', 'Macrocare Tech Co.,Ltd', 'Hàn Quốc')
RETURNING *;

INSERT INTO chemicals (id, manufacturer_id, trade_name, label_name, coa_name)
VALUES ('019c07c3-b612-7483-b6ff-56a3bbcb826b', '019c07bb-018d-7a01-a5d9-10a3ec08ca12', 'Fermented Honey', '', ''),
       ('019c07c3-b616-7ef0-80a5-34b8fe0f2db3', '019c07bb-018d-7a01-a5d9-10a3ec08ca12', 'Nano Bubble Ginger Extract H',
        '', ''),
       ('019c07c3-b616-7f69-97de-99a16ce024ba', '019c07bb-018d-7a01-a5d9-10a3ec08ca12', 'Pink Rockrose Extract', '',
        ''),
       ('019c07c3-b616-7f90-b603-590186cfae00', '019c07bb-0190-779b-85fb-88c2d686d4ff', 'Bakuchiol 99%', '', ''),
       ('019c07c3-b616-7fb2-9a2e-e5254113f9f4', '019c07bb-0190-780d-9368-fb0fea8229cc', 'Vitamin E Acetate 98%', '',
        ''),
       ('019c07c3-b616-7fd2-84c8-eea955612796', '019c07bb-0190-782e-ba1f-fa0d00604e8c', 'Blue - BP(1.5)', '', ''),
       ('019c07c3-b616-7ff6-b8c9-a539dc04204d', '019c07bb-0190-784b-9475-a6929ad5de8b', 'MC-SALICARE', '', '')
RETURNING *;

INSERT INTO chemical_suppliers(supplier_id, chemical_id)
values ('019c07b5-1336-7ed6-9f0d-1d463daaf33f', '019c07c3-b612-7483-b6ff-56a3bbcb826b'),
       ('019c07b5-1336-7ed6-9f0d-1d463daaf33f', '019c07c3-b616-7ef0-80a5-34b8fe0f2db3'),
       ('019c07b5-1336-7ed6-9f0d-1d463daaf33f', '019c07c3-b616-7f69-97de-99a16ce024ba'),
       ('019c07b5-133d-799a-8bbe-aa8aa79797fe', '019c07c3-b616-7f90-b603-590186cfae00'),
       ('019c07b5-133d-799a-8bbe-aa8aa79797fe', '019c07c3-b616-7fb2-9a2e-e5254113f9f4'),
       ('019c07b5-133d-799a-8bbe-aa8aa79797fe', '019c07c3-b616-7fd2-84c8-eea955612796'),
       ('019c07b5-133d-7a2c-b69e-ba5ea7e85bcb', '019c07c3-b616-7ff6-b8c9-a539dc04204d')
RETURNING *;


INSERT INTO chemical_lots (id, chemical_id, batch_number, date_precision)
VALUES ('019c07c8-cbfd-7a87-865f-62ead77f0793', '019c07c3-b612-7483-b6ff-56a3bbcb826b', 'FHP25E28', 'day'),
       ('019c07c8-cc0a-7ad9-b146-9ded5dc96fb5', '019c07c3-b616-7ef0-80a5-34b8fe0f2db3', 'GNB25F17H', 'day'),
       ('019c07c8-cc0a-7da5-814e-4dec4ea833cf', '019c07c3-b616-7f69-97de-99a16ce024ba', 'PREG25E16', 'day'),
       ('019c07c8-cc0a-7f20-ba10-230f675d2e74', '019c07c3-b616-7f90-b603-590186cfae00', '25101802', 'day'),
       ('019c07c8-cc0b-7092-9602-5519b57ab0c3', '019c07c3-b616-7fb2-9a2e-e5254113f9f4', '39685856P0', 'day'),
       ('019c07c8-cc0b-71de-9884-7e4f9fe1c18b', '019c07c3-b616-7fd2-84c8-eea955612796', 'EC3101', 'day'),
       ('019c07c8-cc0b-73b6-a668-a7f39110be88', '019c07c3-b616-7ff6-b8c9-a539dc04204d', 'MCSC240716', 'day')
RETURNING *;

delete from audit_logs;

BEGIN;
WITH new_receipt AS (INSERT INTO chemical_receipts (created_by,status, note) VALUES ('018d4567-e89b-7123-a456-426614174000','DRAFT', 'test') RETURNING id)
INSERT
INTO chemical_receipt_items (receipt_id, chemical_id, lot_id, quantity_received, note)
SELECT r.id, '019c07c3-b612-7483-b6ff-56a3bbcb826b', '019c07c8-cbfd-7a87-865f-62ead77f0793', 200, 'oker'
FROM new_receipt AS r;
COMMIT;

BEGIN;

INSERT INTO chemical_receipts (created_by,status, note) VALUES ('018d4567-e89b-7123-a456-426614174000','DRAFT', 'test') RETURNING *;
COMMIT;

select *
from audit_logs;


select *
from suppliers;
select *
from chemical_manufacturers;
select *
from chemicals;
select *
from chemical_suppliers;
select *
from chemical_lots;

delete
from chemical_lots;

select *
from lot_sequences;