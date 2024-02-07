from contract import w3, contract, accounts


users_accounts = contract.functions.getAccounts().call()
print(users_accounts)