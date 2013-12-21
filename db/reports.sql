---------------------------------
-- Account ledger export
SELECT al.id AS "Código",
CASE
  WHEN al.operation = 'trans' THEN 'Transferencia'  -- trans  = Transfer from one account to other
  WHEN al.operation = 'payin' THEN 'Cobro ingreso'  -- payin  = Payment in Income, adds ++
  WHEN al.operation = 'payout' THEN 'Pago egreso' -- payout = Paymen out Expense, substracts --WHEN al.operation = '
  WHEN al.operation = 'devout' THEN 'Devolucion Ingreso'
  WHEN al.operation = 'devout' THEN 'Devolucion Egreso' -- devout = Devolution out Expense, substracts ++
  WHEN al.operation = 'lrcre' THEN 'Prestamo recibido'  -- lrcre  = Create the ledger Loans::Receive, adds ++
  WHEN al.operation = 'lrpay' THEN 'Pago prestamo'  -- lrpay  = Loans::Receive make a payment, substracts --
  WHEN al.operation = 'lrint' THEN 'Intereses prestamo' -- lrint  = Interest Loans::Receive --
  WHEN al.operation = 'lgcre' THEN 'Prestamo otorgado' -- lgcre  = Create the ledger Loans::Give, substract --
  WHEN al.operation = 'lgint' THEN 'Intereses prestamo' -- lgint  = Interests for Loans::Give ++
  WHEN al.operation = 'lgpay' THEN 'Cobro prestamo' -- lgpay  = Loans::Give receive a payment, adds ++
  WHEN al.operation = 'servex' THEN 'Pago servicio' -- servex = Pays an account with a service account_to is Expense
  WHEN al.operation = 'servin' THEN 'Cobro servicio' -- servin = Pays an account with a service account_to is Income
END AS operacion,
al.amount as cantidad, al.currency as moneda, al.exchange_rate as "tipo de cambio",
al.reference as referencia, a1.name as DE, a2.name as A,
CASE
WHEN a1.type IN ('Income','Expense', 'Loans::Receive', 'Loans::Give') THEN
  c1.matchcode
WHEN a2.type IN ('Income','Expense', 'Loans::Receive', 'Loans::Give') THEN
  c2.matchcode
ELSE
  'Propio'
END AS contacto
FROM account_ledgers al
JOIN accounts a1 ON (a1.id = al.account_id)
JOIN accounts a2 ON (a2.id = al.account_to_id)
LEFT JOIN contacts c1 ON (a1.contact_id = c1.id)
LEFT JOIN contacts c2 ON (a1.contact_id = c2.id);
