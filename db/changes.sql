SET search_path to bonsai;
UPDATE transactions SET total=accounts.amount
FROM accounts
WHERE accounts.id=transactions.account_id 
AND accounts.type IN ('Income', 'Expense');

UPDATE accounts SET amount=transactions.old_balance
FROM transactions
WHERE accounts.id=transactions.account_id 
AND accounts.type IN ('Income', 'Expense');
