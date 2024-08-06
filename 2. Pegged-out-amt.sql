SELECT SUM(amount_msat) / 100000000000 AS total_output_bitcoin
FROM transaction_outputs
WHERE kind = 'wallet';
