-- find many role
SELECT r.id,
       r.name,
       r.description,
       r.status,
       r.deactivated_at,
       r.can_delete,
       r.can_update,
       r.created_at,
       r.updated_at,
       COALESCE(json_agg(json_build_object('id', p.id, 'code', p.code, 'description', p.description, 'join_at',
                                           to_char(rp.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
                                           'created_at',
                                           to_char(p.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')))
                ,
                '[]'::json) AS permissions
FROM roles r
         LEFT JOIN role_permissions rp ON rp.role_id = r.id
         LEFT JOIN permissions p ON p.id = rp.permission_id
GROUP BY r.id, r.name, r.description, r.status, r.deactivated_at, r.can_delete, r.can_update, r.created_at,
         r.updated_at;



