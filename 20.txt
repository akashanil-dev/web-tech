class BankAccount:
    def __init__(self,acc_no,name,acc_type,balance):
        self.acc_no = acc_no
        self.name = name
        self.acc_type = acc_type
        self.balance = balance
    def deposit(self,amount):
        self.balance += amount
        print("\nDeposit amount: ",amount)
        print("Current balance: ",self.balance)
    def withdraw(self,amount):
        if amount <=self.balance:
            self.balance -= amount
            print("\nWithdraw amount: ",amount)
            print("Current balance: ",self.balance)
        else:
            print("Insufficient balance")

acc_no = input("Enter account number: ")
name = input("Enter account holder name: ")
acc_type = input("Enter account type: ")
balance = float(input("Enter initial balance: "))


account = BankAccount(acc_no, name, acc_type, balance)


dep_amt = float(input("\nEnter amount to deposit: "))
account.deposit(dep_amt)

with_amt = float(input("\nEnter amount to withdraw: "))
account.withdraw(with_amt)