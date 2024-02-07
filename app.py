from flask import Flask, render_template, request, url_for, redirect, flash

from contract import w3, contract

app = Flask(__name__)

users_accounts = contract.functions.getAccounts().call()


@app.route('/')
def home():
    return render_template('index.html')


@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == 'GET':
        return render_template('signup.html')
    elif request.method == 'POST':
        try:
            name = request.form['name']
            password = request.form['password']
            address = request.form['address']
            contract.functions.signup(address, name, password).transact({"from": address})
            return redirect(url_for('login'))
        except Exception as e:
            message = 'Error! User already exists'
            print(e)
            render_template('signup.html', message=message)


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'GET':
        return render_template('login.html')
    elif request.method == 'POST':
        address = request.form['address']
        password = request.form['password']
        print(address, password)
        try:
            contract.functions.login(address, password).transact({"from": address})
            return redirect(url_for('signed'))
        except Exception as e:
            print(e)
            message = 'Error! Incorrect address or password'
            return render_template('login.html', message=message)


@app.route('/signed', methods=['GET'])
def signed():
    return render_template('signed.html')


if __name__ == '__main__':
    app.run(debug=True)
