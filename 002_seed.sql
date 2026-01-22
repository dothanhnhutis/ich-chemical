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
                 id)

INSERT INTO role_permissions (role_id, permission_id)
SELECT
    r.id AS role_id,
    p.id AS permission_id
FROM inserted_role r
CROSS JOIN inserted_permission p
ON CONFLICT DO NOTHING;



COMMIT;



delete  from roles;
delete  from permissions;
delete  from role_permissions;

