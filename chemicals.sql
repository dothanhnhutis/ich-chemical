BEGIN;

WITH new_supplier AS (
    INSERT INTO suppliers (company_name, company_abbreviation)
        VALUES ('CÔNG TY TNHH IWASE COSFA VIỆT NAM', 'Iwase Cosfa VN')
        RETURNING id),
     new_manufacturer AS (
         INSERT INTO chemical_manufacturers (name, origin_country)
             VALUES ('KATAKURA & CO-OP AGRI CORP', 'Nhật Bản')
             RETURNING id)
INSERT
INTO chemicals (manufacturer_id, trade_name, label_name, coa_name, cas_number, function, appearance, min_stock_level)
SELECT id,
       'Fermented Honey',
       '',
       'Fermented Honey',
       '',
       '',
       NULL,
       0 -- Thêm 0 hoặc giá trị mặc định cho min_stock_level nếu cần
FROM new_manufacturer;

COMMIT;



insert into chemical_lots (lot_no, chemical_id, batch_number, date_precision, manufactured_date, expiry_date)
values ('ICHLOT123123123215', '019c047e-cb93-75fa-b4e2-211f791e9650', 'FHP25E28', 'month', '2026-01-01', '2027-01-01')
returning *;



select *
from chemicals;

select *
from chemical_lots;

delete
from suppliers;
delete
from chemical_manufacturers;
delete
from chemicals;

delete
from chemical_lots;