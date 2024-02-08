from flask import Flask, render_template, request, url_for, redirect, flash

from contract import w3, contract, accounts


app = Flask(__name__)


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
        print(address, password)
        try:
            contract.functions.login(address, password).transact({"from": address})
            return redirect(url_for('signed', user=address))
        except Exception as e:
            print(e)
            message = 'Error! Incorrect address or password'
            return render_template('login.html', message=message, users_accounts=users_accounts)


@app.route('/MyAccount', methods=['GET', 'POST'])
def signed():
    user = request.args.get('user')
    name = contract.functions.getInformation(user).call()
    balance = 100
    return render_template('signed.html', user=user, name=name, balance=balance)


if __name__ == '__main__':
    app.run(debug=True)
