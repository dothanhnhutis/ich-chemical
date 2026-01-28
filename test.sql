INSERT INTO suppliers (company_name, company_abbreviation)
VALUES ('CÔNG TY TNHH IWASE COSFA VIỆT NAM', 'Iwase Cosfa VN'),
       ('CÔNG TY TNHH KHANG NGOC', 'Khang Ngọc'),
       ('CÔNG TY TNHH INTRIE COSMETIC', 'Intrie Cosmetic')
RETURNING *;


INSERT INTO chemical_manufacturers (name, origin_country)
VALUES ('KATAKURA & CO-OP AGRI CORP', 'Nhật Bản'),
       ('Sinoway Industrial Co.,Ltd', 'Trung Quốc'),
       ('BASF SE', 'Đức'),
       ('CoSeedBioPharm Co., Ltd', 'Hàn Quốc'),
       ('Macrocare Tech Co.,Ltd', 'Hàn Quốc')
RETURNING *;

INSERT INTO chemicals (manufacturer_id, trade_name, label_name, coa_name)
VALUES ('019c04b1-60a7-72e9-ba00-1379c1fa4d3d', 'Fermented Honey', '', ''),
       ('019c04b1-60a7-72e9-ba00-1379c1fa4d3d', 'Nano Bubble Ginger Extract H', '', ''),
       ('019c04b1-60a7-72e9-ba00-1379c1fa4d3d', 'Pink Rockrose Extract', '', ''),
       ('019c04b1-60a7-7792-be9d-b91968c8593d', 'Bakuchiol 99%', '', ''),
       ('019c04b1-60a7-77c3-9053-4475f7c1f6a3', 'Vitamin E Acetate 98%', '', ''),
       ('019c04b1-60a7-77d9-8517-216fc2eaf903', 'Blue - BP(1.5)', '', ''),
       ('019c04b1-60a7-77ed-9039-dda9c708ed25', 'MC-SALICARE', '', '')
RETURNING *;

INSERT INTO chemical_suppliers(supplier_id, chemical_id)
values ('019c04b0-e59f-7338-b68e-aa6de414c654', '019c04b3-8837-7b85-8e42-630b8838912a'),
       ('019c04b0-e59f-7338-b68e-aa6de414c654', '019c04b3-8837-7f55-b235-3ecd0584fd81'),
       ('019c04b0-e59f-7338-b68e-aa6de414c654', '019c04b3-8837-7f87-b2fb-aa12d6815105'),
       ('019c04b0-e59f-7b08-80c6-af5f09508e96', '019c04b3-8837-7f9f-ab1f-714739377a74'),
       ('019c04b0-e59f-7b08-80c6-af5f09508e96', '019c04b3-8837-7fb4-b8a4-f62bf3f839ff'),
       ('019c04b0-e59f-7b08-80c6-af5f09508e96', '019c04b3-8837-7fc8-8aa7-e5cee071c33e'),
       ('019c04b0-e59f-7b4b-b690-50d78f6809b4', '019c04b3-8837-7fe3-b6b4-7d02248afd5c')
RETURNING *;


INSERT INTO chemical_lots (chemical_id, batch_number, date_precision)
VALUES ('019c04b3-8837-7b85-8e42-630b8838912a', 'FHP25E28', 'day'),
       ('019c04b3-8837-7f55-b235-3ecd0584fd81', 'GNB25F17H', 'day'),
       ('019c04b3-8837-7f87-b2fb-aa12d6815105', 'PREG25E16', 'day'),
       ('019c04b3-8837-7f9f-ab1f-714739377a74', '25101802', 'day'),
       ('019c04b3-8837-7fb4-b8a4-f62bf3f839ff', '39685856P0', 'day'),
       ('019c04b3-8837-7fc8-8aa7-e5cee071c33e', 'EC3101', 'day'),
       ('019c04b3-8837-7fe3-b6b4-7d02248afd5c', 'MCSC240716', 'day')
RETURNING *;



BEGIN;
SET LOCAL app.current_user_id = '018d4567-e89b-7123-a456-426614174000';

with new_receipt as (INSERT INTO chemical_receipts (status, note) VALUES ('DRAFT', 'test') RETURNING id)
insert
into chemical_receipt_items (receipt_id, chemical_id, lot_id, quantity_received, note)
SELECT r.id, '019c04b3-8837-7b85-8e42-630b8838912a', '019c04f6-04e7-7079-8c00-a3d34f38a687', 200, 'oker'
FROM new_receipt as r;
COMMIT;


select * from audit_logs;


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