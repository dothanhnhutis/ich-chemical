INSERT INTO role_permissions (role_id, permission_id)
VALUES ('019c0e41-9c74-7a26-93d9-a011e8916495', '019c0e49-e046-7118-84cb-24bbec0d80cb'),
       ('019c0e41-9c74-7a26-93d9-a011e8916495', '019c0e49-e048-7118-8f39-3bcfa07c4442');




BEGIN;
SELECT set_config('ich_app.current_user_id', 'user-B', true);
INSERT INTO permissions (code, description)
VALUES ('USER_VIEW2', 'Xem danh sách user')
ON CONFLICT (code) DO NOTHING
RETURNING *;
COMMIT;


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
    ON CONFLICT (code) DO NOTHING RETURNING id)
INSERT
INTO roles (name, description, can_delete, can_update)
VALUES ('Super Admin',
        'Vai trò khởi tạo từ hệ thống.',
        false,
        false);
COMMIT;


select *
from audit_logs;

delete
from roles;
delete
from permissions;
delete
from role_permissions;
delete
from audit_logs;

drop trigger trg_roles on roles;
drop trigger trg_role_permissions on role_permissions;
drop trigger trg_permissions on permissions;

