-- Users in organisation MySQL
SELECT links.user_id, users.email, CONCAT(users.first_name, users.last_name) AS user_name
, organisations.name AS organisation, organisations.id AS organisation_id
FROM links
JOIN organisations ON ( organisations.id = links.organisation_id )
JOIN users ON (users.id = links.user_id)
ORDER BY links.organisation_id
LIMIT 0, 100;

-- Ussage MySQL
SELECT organisations.id, organisations.name, SUM(org_trans) AS org_trans,
SUM(org_ledgers) AS org_ledgers, SUM(org_items) AS org_items, SUM(org_contacts) AS org_contacts
FROM organisations
JOIN (
  SELECT transactions.organisation_id, COUNT(transactions.id) AS org_trans,
  0 AS org_ledgers, 0 AS org_items, 0 AS org_contacts
  FROM transactions GROUP BY transactions.organisation_id
  UNION
  SELECT account_ledgers.organisation_id, 0 AS org_trans,
  COUNT(account_ledgers.id) as org_ledgers, 0 AS org_items, 0 AS org_contacts
  FROM account_ledgers GROUP BY account_ledgers.organisation_id
  UNION
  SELECT items.organisation_id, 0 AS org_trans,
  0 as org_ledgers, COUNT(items.id) AS org_items, 0 AS org_contacts
  FROM items GROUP BY items.organisation_id
  UNION
  SELECT contacts.organisation_id, 0 AS org_trans,
  0 as org_ledgers, 0 AS org_items, COUNT(contacts.id) as org_contacts
  FROM contacts GROUP BY contacts.organisation_id
) AS tmp ON (tmp.organisation_id = organisations.id)
GROUP BY tmp.organisation_id
LIMIT 0, 100;

-- PostgreSQL
-- sudo -u postgres psql postgres
-- \? # Help
SELECT u.email, o.name FROM users u LEFT JOIN links l ON (u.id = l.user_id)
LEFT JOIN organisations o ON (o.id = l.organisation_id);


-- Data dsigregated
SELECT det.item_id, items.name, det.quantity , accounts.due_date, accounts.created_at
FROM accounts
JOIN movement_details AS det ON (accounts.id = det.account_id )
JOIN items ON (items.id = det.item_id)
WHERE type = 'Income' AND state = 'approved'
