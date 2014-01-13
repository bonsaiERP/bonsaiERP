SELECT u.id, u.email, u.last_sign_in_at, o.tenant FROM common.users u
JOIN common.links l ON (u.id = l.user_id)
JOIN common.organisations o ON (o.id = l.organisation_id)
ORDER BY o.tenant;
