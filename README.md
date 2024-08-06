# Fedimint challenge

## Basic Challenge
> **TASK:** You are provided with a fedimint-observer.db sqlite file from a Fedimint Observer configured to
monitor the Bitcoin Principles Fedimint federation. We would like you to answer the following
questions using this database:
> 1. How much Bitcoin was pegged-in to this federation?
> 2. How much Bitcoin was pegged-out from this federation?
> 3. What is the current on-chain balance of this federation?

## Solution
### My Understanding of Pegged-In and Pegged-Out Transactions in the Fedimint Federation

#### Pegged-in
When a user wants to peg-in, they start by depositing Bitcoin into the Fedimint federation. After the deposit is confirmed, the federation mints an equivalent amount of e-cash (fm-BTC) and credits it to the user's wallet, providing them with e-cash backed 1:1 by their deposited Bitcoin. The Fedi wallet plays a crucial role in this process, securely holding the Bitcoin and managing the issuance of e-cash. It serves as an interface for users to monitor their balances and transaction history.

#### Pegged-out
For pegging-out, the user initiates a withdrawal request through their wallet to convert their e-cash back into Bitcoin. The federation responds by burning the equivalent amount of e-cash, effectively removing it from circulation. After the e-cash is burned, the corresponding amount of Bitcoin is released to the user's wallet. Throughout this process, the wallet manages the user's e-cash and facilitates the receipt of Bitcoin, ensuring a smooth transition from e-cash to external assets.

### 1. How much Bitcoin was pegged-in to this federation?

In the `fedimint-observer.db`, `transaction_inputs` table is used to track the specific inputs for each transaction within the federation, helping in verifying and auditing transactions. The main columns in `transaction_inputs` for this task includes:

- in_index - the index of the input transaction of each ID
- kind - the type or kind of the input
  - `ln`: Input transactions associated with the Lightning Network
  - `mint`: Input transactions that involve the minting of e-cash
  - `wallet`: Input transactions that are directly related to wallet operations.
  - `stabilty_pool`: Input transactions related to a stability pool
- amount_msat -  holds the amount of the input in millisatoshis

To calculate the total Bitcoin amount that was pegged-in to this federation, we need to consider the `wallet` kind for one main reasons:

1. When analyzing pegged-in transactions in the Fedimint federation, it’s important to focus on the `wallet` kind in the `fedimint-observer.db`. Specifically, the `in_index` column indicates the index of the input transaction within the federation. For pegged-in transactions, we are interested in those with an `in_index` value of 0, which represents the first input transaction. By filtering the `transaction_inputs` table for rows where the `kind` is 'wallet' and the `in_index` is 0, we observe that all transactions of the `wallet` kind have this `in_index` value, unlike transactions of the `mint` kind, which may have multiple index values. This indicates that `wallet` kind transactions are the first input transactions in the federation.


SQL query: Retrieving All 'Wallet' Transactions from Inputs Table
```
SELECT *
FROM transaction_inputs
WHERE kind = 'wallet';
```

Output:

![Screenshot (313)](https://github.com/user-attachments/assets/e9d848bc-f569-400f-b1a0-ea10db6d9ec5)

## Final Solution:

### Total amount of Bitcoin pegged-in to this federation

SQL query: Total Bitcoin from 'Wallet' Transactions in Inputs
```
SELECT SUM(amount_msat) / 100000000000 AS total_input_bitcoin
FROM transaction_inputs
WHERE kind = 'wallet';
```

Output: 

### **Solution:** total_bitcoins = 8

![Screenshot (316)](https://github.com/user-attachments/assets/2693e162-2f03-4da2-beba-ac0f40bccaf4)


### 2. How much Bitcoin was pegged-out from this federation?

Similar to pegged-in, `transaction_outputs` table is used to track the specific outputs for each transaction within the federation, helping in verifying and auditing transactions. The main columns in `transaction_outputs` for this task include:

- out_index - the index of the output transaction of each ID
- kind - the type or kind of the output
  - `ln`: Output transactions associated with the Lightning Network
  - `mint`: Output transactions that involve the minting of e-cash
  - `wallet`: Output transactions that are directly related to wallet operations.
  - `stabilty_pool`: Output transactions related to a stability pool
- amount_msat -  holds the amount of the output in millisatoshis

To calculate the total Bitcoin amount that was pegged-out to this federation, we need to consider the `wallet` kind for two main reasons:

1. Similar to pegged-in, all transactions of the `wallet` kind have an `out_index` value of 0, which indicates that an output transaction can only be performed once, or as a final transaction, to peg out from the federation.

Output: Retrieving All 'Wallet' Transactions from Outputs Table

![Screenshot (317)](https://github.com/user-attachments/assets/312410cc-3df5-4456-963e-835e167fac76)

2. All output transactions (amount_msat) of the `wallet` kind must be less than the input transactions (amount_msat) of the `wallet` kind. To verify this, I ran the query below to check for any output transaction amounts greater than input transaction amounts for the `wallet` kind. The result confirmed that there were no output transactions greater than the input transactions.

SQL query: Identifying Larger 'Wallet' Transactions in Outputs Compared to Inputs
```
SELECT *
FROM transaction_outputs
WHERE kind = 'wallet'
AND amount_msat > (SELECT MAX(amount_msat) FROM transaction_inputs WHERE kind = 'wallet');
```

Output: NO-OUTPUT

## Final Solution:

### Total amount of Bitcoin pegged-out from this federation

SQL query: Total Bitcoin from 'Wallet' Transactions in Inputs
```
SELECT SUM(amount_msat) / 100000000000 AS total_output_bitcoin
FROM transaction_outputs
WHERE kind = 'wallet';
```

Output: 

### **Solution:** total_bitcoins = 7

![Screenshot (315)](https://github.com/user-attachments/assets/32704d10-b04e-4ad9-aeee-92d13ae2365b)


### 3. What is the current on-chain balance of this federation?

## Solution
To calculate the on-chain balance, we simply consider the sum of Bitcoin amounts that have been deposited (pegged-in) minus the sum of Bitcoin amounts that have been withdrawn (pegged-out).

SQL query: Calculate Wallet Balance from Transaction Inputs and Outputs
```
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
```

Output: 

### **Solution:** total_balance = 1

![Screenshot (318)](https://github.com/user-attachments/assets/4c5a6b61-3bde-4a20-946d-f9386f5224d9)


## Final Solution:

### 1. How much Bitcoin was pegged-in to this federation?

#### Solution: 8

### 2. How much Bitcoin was pegged-out from this federation?

#### Solution: 7

### 3. What is the current on-chain balance of this federation?

#### Solution: 1
