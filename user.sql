SELECT u.id,
       u.email,
       u.password_hash,
       u.username,
       u.status,
       u.deactivated_at,
       u.created_at,
       u.updated_at,
       COALESCE(json_agg(json_build_object('id', r.id,
                                           'name', r.name,
                                           'description', r.description,
                                           'status', r.status,
                                           'deactivated_at', r.deactivated_at,
                                           'can_delete', r.can_delete,
                                           'can_update', r.can_update,
                                           'created_at', r.created_at,
                                           'updated_at', r.updated_at)) FILTER (WHERE r.id IS NOT NULL), '[]'::json) AS roles
FROM users u
         LEFT JOIN user_roles ur ON ur.user_id = u.id
         LEFT JOIN roles r ON r.id = ur.role_id AND r.deactivated_at IS NULL
         LEFT JOIN role_permissions rp ON rp.role_id = r.id
         LEFT JOIN permissions p ON p.id = rp.permission_id
WHERE email = 'gaconght@gmail.com'
GROUP BY u.id, u.email, u.password_hash, u.username, u.status, u.deactivated_at, u.created_at, u.updated_at;