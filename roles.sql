-- find many
-- EXPLAIN ANALYZE
-- SELECT r.id, r.name, r.description, r.status,r.deactivated_at,r.deleted_at,r.can_update,r.created_at,r.updated_at,
--         COALESCE( jsonb_agg(p),'[]') AS permissions
-- FROM roles r
--          LEFT JOIN role_permissions rp ON rp.role_id = r.id
--          LEFT JOIN permissions p ON p.id = rp.permission_id
-- GROUP BY r.id, r.name, r.description, r.status,r.deactivated_at,r.deleted_at,r.can_update,r.created_at,r.updated_at;

-- findManyPermissions
SELECT * FROM permissions;


-- findManyRoles
EXPLAIN ANALYZE
SELECT r.*,
       p_agg.permissions
FROM roles r
         LEFT JOIN LATERAL (
    SELECT COALESCE(jsonb_agg(p.*), '[]') AS permissions
    FROM role_permissions rp
             JOIN permissions p ON p.id = rp.permission_id
    WHERE rp.role_id = r.id -- Kết nối với dòng hiện tại của bảng r
    ) p_agg ON TRUE;


-- findRoleById
SELECT r.*,
       p_agg.permissions
FROM roles r
LEFT JOIN LATERAL (
    SELECT COALESCE(jsonb_agg(p.*), '[]') AS permissions
    FROM role_permissions rp
    JOIN permissions p ON p.id = rp.permission_id
    WHERE rp.role_id = r.id  -- Kết nối với dòng hiện tại của bảng r
) p_agg ON TRUE
WHERE id = '019c0e41-9c74-7a26-93d9-a011e8916495';





