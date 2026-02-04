-- findUserPasswordByEmail /users/:email
SELECT *
FROM users
WHERE email = 'gaconght@gmail.com';

-- findUserPasswordById /users/:id
SELECT *
FROM users u
         LEFT JOIN LATERAL (
    SELECT (to_jsonb(f.*) || jsonb_build_object('width', ua.width, 'height', ua.height)) AS avatar
    FROM files f
             INNER JOIN user_avatars ua ON ua.file_id = f.id
    WHERE ua.user_id = u.id
      AND ua.is_primary IS TRUE
    LIMIT 1
    ) ON TRUE
WHERE u.id = '019c1e90-9f8b-7471-8f65-94d40da50c26';

-- findUserPermission /users/:id/roles/permissions
SELECT DISTINCT p.*
FROM permissions p
         LEFT JOIN role_permissions rp ON p.id = rp.permission_id
         LEFT JOIN user_roles ur ON rp.role_id = ur.role_id
WHERE ur.user_id = '019c0df7-89b5-7628-a136-d9d9d00bf754';

-- findUserPermissionCode /users/:id/roles/permissions/code
SELECT DISTINCT p.code
FROM permissions p
         LEFT JOIN role_permissions rp ON p.id = rp.permission_id
         LEFT JOIN user_roles ur ON rp.role_id = ur.role_id
WHERE ur.user_id = '019c0df7-89b5-7628-a136-d9d9d00bf754';

-- findUserRoleDetail /users/:id/roles
SELECT r.*, ur.created_at as join_at, COALESCE(p_agg.permissions, '[]') AS permissions
FROM roles r
         LEFT JOIN user_roles ur ON r.id = ur.role_id
         LEFT JOIN LATERAL (SELECT jsonb_agg(p.*) AS permissions
                            FROM permissions p
                                     LEFT JOIN role_permissions rp ON rp.permission_id = p.id
                            WHERE rp.role_id = r.id
    ) p_agg ON TRUE
WHERE ur.user_id = '019c0df7-89b5-7628-a136-d9d9d00bf754';

