-- find many
SELECT r.id, r.name, r.description, r.status,r.deactivated_at,r.deleted_at,r.can_update,r.created_at,r.updated_at,
        COALESCE( jsonb_agg(p),'[]') AS permissions
FROM roles r
         LEFT JOIN role_permissions rp ON rp.role_id = r.id
         LEFT JOIN permissions p ON p.id = rp.permission_id
GROUP BY r.id, r.name, r.description, r.status,r.deactivated_at,r.deleted_at,r.can_update,r.created_at,r.updated_at;

-- find
SELECT r.*,
    (SELECT COALESCE(json_agg(p.*), '[]')
     FROM role_permissions rp
     JOIN permissions p ON p.id = rp.permission_id
     WHERE rp.role_id = r.id) AS permissions
FROM roles r;

