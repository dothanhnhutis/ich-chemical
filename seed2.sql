--
CREATE OR REPLACE FUNCTION fn_generic_audit_log()
    RETURNS TRIGGER AS
$$
DECLARE
    v_tx_id   TEXT;
    v_user_id TEXT;
BEGIN
    -- 1. Transaction ID (batch id)
    v_tx_id := current_setting('kk.current_transaction_id', true);
--     v_tx_id := txid_current()::TEXT;

    IF v_tx_id IS NULL THEN
        v_tx_id := uuidv7()::TEXT;
        PERFORM set_config(
                'kk.current_transaction_id',
                v_tx_id, true
                );
    END IF;

    -- 2. User ID (từ app context)
    v_user_id := current_setting('kk.current_user_id', true);

    -- 3. Audit log
    INSERT INTO audit_logs (transaction_id,
                            table_name,
                            record_id,
                            action,
                            old_data,
                            new_data,
                            changed_by)
    VALUES (v_tx_id,
            TG_TABLE_NAME,
            CASE
                WHEN TG_OP = 'DELETE' THEN OLD.id::TEXT
                ELSE NEW.id::TEXT
                END,
            TG_OP,
            CASE
                WHEN TG_OP <> 'INSERT' THEN to_jsonb(OLD)
                END,
            CASE
                WHEN TG_OP <> 'DELETE' THEN to_jsonb(NEW)
                END,
            COALESCE(v_user_id, 'SYSTEM'));

    -- AFTER trigger only
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_permissions
    AFTER INSERT OR UPDATE OR DELETE
    ON permissions
    FOR EACH ROW
EXECUTE FUNCTION fn_generic_audit_log();

CREATE TRIGGER trg_roles
    AFTER INSERT OR UPDATE OR DELETE
    ON roles
    FOR EACH ROW
EXECUTE FUNCTION fn_generic_audit_log();

CREATE TRIGGER trg_role_permissions
    AFTER INSERT OR UPDATE OR DELETE
    ON role_permissions
    FOR EACH ROW
EXECUTE FUNCTION fn_generic_audit_log();


BEGIN;
SELECT set_config('kk.current_user_id', 'user-B', true);
INSERT INTO permissions (code, description)
VALUES ('USER_VIEW3', 'Xem danh sách user')
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


-- SESSION 1
SELECT set_config('ich.user_id', 'user-A', false);
-- Session-level
-- ✅ Giá trị: 'user-A'

BEGIN;
SET LOCAL ich.user_id = 'user-B';
-- SELECT set_config('ich.user_id', 'user-B', true);
-- Transaction-level
-- ✅ Giá trị: 'user-B' (override session-level)

SELECT current_setting('ich.user_id', true);
-- Result: 'user-B'
COMMIT;

SELECT current_setting('ich.user_id', true);
-- Result: 'user-A'  (quay lại session-level)
