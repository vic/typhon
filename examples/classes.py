# -*- coding: utf-8 -*-

class BankAccount(object):

    def __init__(self, initial_balance=0):

        self.balance = initial_balance

    def deposit(self, amount):

        self.balance = self.balance + amount

    def withdraw(self, amount):

        self.balance = self.balance - amount

    def overdrawn(self):

        return self.balance < 0


print BankAccount
my_account = BankAccount(15)
print my_account
my_account.withdraw(5)
print my_account.balance
