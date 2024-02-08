from flask import Flask, render_template, request, url_for, redirect, session

from contract import w3, contract, accounts
import time

app = Flask(__name__)
app.secret_key = 'blockchain123'


def add_account(address):
    session['address'] = address


def view_account():
    account = session.get('address')
    return account


@app.route('/')
def home():
    return render_template('index.html')


@app.route('/signup', methods=['GET', 'POST'])
def signup():
    users_accounts = contract.functions.getAccounts().call()
    users_reg = list(set(accounts).difference(set(users_accounts)))
    if request.method == 'GET':
        return render_template('signup.html', users_reg=users_reg)
    elif request.method == 'POST':
        name = request.form['name']
        password = request.form['password']
        address = request.form['address']
        print(name, password, address)
        try:
            contract.functions.signup(address, name, password).transact({"from": address})
            return redirect(url_for('login', users_accounts=users_accounts))
        except Exception as e:
            message = 'Error! User already exists'
            print(e)
            render_template('signup.html', message=message, users_reg=users_reg)


@app.route('/login', methods=['GET', 'POST'])
def login():
    users_accounts = contract.functions.getAccounts().call()
    if request.method == 'GET':
        return render_template('login.html', users_accounts=users_accounts)
    elif request.method == 'POST':
        address = request.form['address']
        password = request.form['password']
        try:
            contract.functions.login(address, password).transact({"from": address})
            add_account(address)
            return redirect(url_for('signed'))
        except Exception as e:
            print(e)
            message = 'Error! Incorrect address or password'
            return render_template('login.html', message=message, users_accounts=users_accounts)


@app.route('/MyAccount', methods=['GET', 'POST'])
def signed():
    user = view_account()
    name = contract.functions.getInformation(user).call()
    balance = contract.functions.getBalance(user).call()
    balance_view = f'{balance} Ether'
    session['balance'] = balance
    return render_template('signed.html', user=user, name=name, balance_view=balance_view)


@app.route('/transfer', methods=['GET', 'POST'])
def transfer():
    users_accounts = contract.functions.getAccounts().call()
    user = view_account()
    balance = session.get('balance')
    login_accounts = list(set(users_accounts[users_accounts.index(user)]).difference(set(user)))
    if request.method == 'POST':
        recipient = request.form['recipient']
        sum = request.form['sum']
        if not login_accounts:
            message = 'There are no other registered accounts. Try again later!'
            return render_template('transfer.html', login_accounts=login_accounts, balance=balance,
                                   message=message)
    return render_template('transfer.html', login_accounts=login_accounts, balance=balance)


if __name__ == '__main__':
    app.run(debug=True)
