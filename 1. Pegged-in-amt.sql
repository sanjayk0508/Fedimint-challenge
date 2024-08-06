SELECT SUM(amount_msat) / 100000000000 AS total_input_bitcoin
FROM transaction_inputs
WHERE kind = 'wallet';
