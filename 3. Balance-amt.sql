SELECT 
    ( 
        (SELECT SUM(amount_msat) / 100000000000 AS total_bitcoin
         FROM transaction_inputs
         WHERE kind = 'wallet') 
        - 
        (SELECT SUM(amount_msat) / 100000000000 AS total_bitcoin
         FROM transaction_outputs
         WHERE kind = 'wallet')
    ) AS balance;
