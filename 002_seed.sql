-- seed production
COPY users
    FROM '/data_csv/permissions.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY users
    FROM '/data_csv/roles.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY users
    FROM '/data_csv/role_permissions.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY users
    FROM '/data_csv/users.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

COPY users
    FROM '/data_csv/user_roles.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');


-- seed dev

INSERT INTO permissions (code, description)
    VALUES ('USER_VIEW', 'Xem danh sách user'),
           ('USER_CREATE', 'Tạo user'),
           ('USER_UPDATE', 'Cập nhật user'),
           ('USER_DELETE', 'Xoá user'),

           ('ROLE_VIEW', 'Xem role'),
           ('ROLE_CREATE', 'Tạo role'),
           ('ROLE_UPDATE', 'Cập nhật role'),
           ('ROLE_DELETE', 'Xoá role'),

           ('CHEMICAL_VIEW', 'Xem nguyên liệu'),
           ('CHEMICAL_CREATE', 'Tạo nguyên liệu'),
           ('CHEMICAL_UPDATE', 'Cập nhật nguyên liệu'),
           ('CHEMICAL_DELETE', 'Xoá nguyên liệu'),

           ('ORDER_VIEW', 'Xem đơn nhập'),
           ('ORDER_CREATE', 'Tạo đơn nhập'),
           ('ORDER_UPDATE', 'Cập nhật đơn nhập'),
           ('ORDER_CANCEL', 'Huỷ đơn nhập'),

           ('RECEIPT_VIEW', 'Xem phiếu nhận'),
           ('RECEIPT_CREATE', 'Tạo phiếu nhận'),

           ('STOCK_VIEW', 'Xem tồn kho'),
           ('STOCK_ADJUST', 'Điều chỉnh tồn kho')
    ON CONFLICT (code) DO NOTHING RETURNING *;


--- Tạo tài khoản user và role với transaction
BEGIN;
WITH inserted_permission AS ( INSERT INTO permissions (code, description)
    VALUES ('USER_VIEW', 'Xem danh sách user'),
           ('USER_CREATE', 'Tạo user'),
           ('USER_UPDATE', 'Cập nhật user'),
           ('USER_DELETE', 'Xoá user'),

           ('ROLE_VIEW', 'Xem role'),
           ('ROLE_CREATE', 'Tạo role'),
           ('ROLE_UPDATE', 'Cập nhật role'),
           ('ROLE_DELETE', 'Xoá role'),

           ('CHEMICAL_VIEW', 'Xem nguyên liệu'),
           ('CHEMICAL_CREATE', 'Tạo nguyên liệu'),
           ('CHEMICAL_UPDATE', 'Cập nhật nguyên liệu'),
           ('CHEMICAL_DELETE', 'Xoá nguyên liệu'),

           ('ORDER_VIEW', 'Xem đơn nhập'),
           ('ORDER_CREATE', 'Tạo đơn nhập'),
           ('ORDER_UPDATE', 'Cập nhật đơn nhập'),
           ('ORDER_CANCEL', 'Huỷ đơn nhập'),

           ('RECEIPT_VIEW', 'Xem phiếu nhận'),
           ('RECEIPT_CREATE', 'Tạo phiếu nhận'),

           ('STOCK_VIEW', 'Xem tồn kho'),
           ('STOCK_ADJUST', 'Điều chỉnh tồn kho')
    ON CONFLICT (code) DO NOTHING RETURNING id),
     inserted_role AS (
         INSERT INTO
             roles (name, description, can_delete, can_update)
             VALUES ('Super Admin',
                     'Vai trò khởi tạo từ hệ thống.',
                     false,
                     false)
             RETURNING
                 id),
     inserted_role_permission AS (INSERT
         INTO role_permissions (role_id, permission_id)
             SELECT r.id AS role_id,
                    p.id AS permission_id
             FROM inserted_role r
                      CROSS JOIN inserted_permission p
             ON CONFLICT DO NOTHING),
     inserted_user AS (INSERT
         INTO users (email, username, password_hash)
             VALUES ('gaconght@gmail.com',
                     'Thanh Nhut',
                     '$argon2id$v=19$m=65536,t=3,p=4$oDdsbvL66JBFGcGtpM2bVQ$BSuYE86W6ALjeRJmC9I5sv/pr6xXJj3eFGvgS+aF7Io')
             RETURNING id)

INSERT
INTO user_roles (user_id, role_id)
SELECT u.id AS user_id, r.id AS role_id
FROM inserted_user u
         CROSS JOIN inserted_role r;
COMMIT;



