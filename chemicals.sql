BEGIN;

WITH new_supplier
         as (INSERT INTO suppliers (company_name, company_abbreviation) VALUES ('CÔNG TY TNHH IWASE COSFA VIỆT NAM', 'Iwase Cosfa VN') returning id)
     INSERT INTO chemical_manufacturers (name, origin_country) VALUES ('KATAKURA & CO-OP AGRI CORP', 'Nhật Bản') RETURNING id;


COMMIT;
END;