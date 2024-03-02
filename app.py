from flask import Flask, render_template, request, url_for, redirect, session

from contract import w3, contract, accounts

app = Flask(__name__)
app.secret_key = 'blockchain123'


def add_account(address):
    session['address'] = address


def view_account():
    account = session.get('address', None)
    return account


@app.route('/')
def home():
    if view_account() is not None:
        return redirect(url_for('signed'))
    else:
        return render_template('index.html')


@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if view_account() is not None:
        return redirect(url_for('signed'))
    else:
        users_accounts = contract.functions.getAccounts().call()
        users_reg = list(set(accounts).difference(set(users_accounts)))
        if request.method == 'GET':
            return render_template('signup.html', users_reg=users_reg)
        elif request.method == 'POST':
            name = request.form['name']
            password = request.form['password']
            address = request.form['address']
            try:
                contract.functions.signup(name, password).transact({"from": address})
                return redirect(url_for('login', users_accounts=users_accounts))
            except Exception as e:
                message = 'Error! User already exists'
                print(e)
                render_template('signup.html', message=message, users_reg=users_reg)


@app.route('/login', methods=['GET', 'POST'])
def login():
    if view_account() is not None:
        return redirect(url_for('signed'))
    else:
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
    if view_account() is None:
        return redirect(url_for('home'))
    else:
        user = view_account()
        name = contract.functions.getInformation(user).call()
        balance_checkSum = w3.to_checksum_address(user)
        balance = w3.from_wei((w3.eth.get_balance(balance_checkSum)), 'ether')
        balance_view = f'{balance} Ether'
        balance_token = contract.functions.getBalanceToken().call({'from': user})
        return render_template('signed.html', user=user, name=name, balance_view=balance_view,
                               balance_token=balance_token)


@app.route('/logout')
def logout():
    session.pop('address', None)
    return redirect(url_for('home'))


@app.route('/transfer', methods=['GET', 'POST'])
def transfer():
    if view_account() is None:
        return redirect(url_for('home'))
    else:
        users_accounts = contract.functions.getAccounts().call()
        user = view_account()
        login_accounts = [i for i in users_accounts if i != user]
        if request.method == 'POST':
            currency = request.form['currency']
            recipient = request.form['recipient']
            sum = int(request.form['sum'])
            try:
                if currency == 'ETH':
                    sum = sum * 10 ** 18
                    contract.functions.sendToTransfer(recipient).transact({'from': user, 'value': sum})
                else:
                    contract.functions.sendTransferToken(recipient, sum).transact({'from': user})
                return render_template('transfer.html', login_accounts=login_accounts,
                                       message='Transfer successful')
            except Exception as e:
                print(e)
                return render_template('transfer.html', login_accounts=login_accounts,
                                       message='Error! Incorrect data')
        return render_template('transfer.html', login_accounts=login_accounts)


@app.route('/transfer_history', methods=['GET', 'POST'])
def transfer_history():
    if view_account() is None:
        return redirect(url_for('home'))
    else:
        transfers = contract.functions.getTransfers().call()
        flag = 0
        for i in transfers:
            if i[1] == view_account() or i[2] == view_account():
                flag += 1
        if not flag:
            message = 'There are no transfers'
            return render_template('transfer_history.html', message=message)
        if request.method == 'POST':
            try:
                contract.functions.getTotransfer(int(request.form.get('transfer_id'))).transact(
                    {'from': view_account()})
                return redirect('transfer_history')
            except Exception as e:
                print(e)
                return render_template('transfer_history.html', transfers=transfers,
                                       message='Transfer failed', user=view_account())
        return render_template('transfer_history.html', transfers=transfers, user=view_account())


@app.route('/trading_platform', methods=['GET', 'POST'])
def trading_platform():
    NFT_list = contract.functions.getArrayNFT().call()
    return render_template('trading_platform.html', Nft_list=NFT_list, user=view_account())


@app.route('/create_nft', methods=["GET", "POST"])
def create_nft():
    if request.method == 'POST':
        name = request.form.get('name')
        picture = request.files.get('image')
        amount = int(request.form.get('amount'))
        contract.functions.createNft(name, picture.name, amount).transact({'from': view_account()})
        return redirect(url_for('signed'))
    return render_template('create_nft.html')


@app.route('/my_nft', methods=["GET", "POST"])
def my_nft():
    NFT_list = contract.functions.getArrayNFT().call()
    # [('0xeC5c22233B644f70BD567014d8473cB7B229d03C', 0, 'GOLD', 'monkey0.png', 3, false, false)]
    if request.method == 'POST':
        amount = int(request.form.get('amount'))
        price = int(request.form.get('price'))
        nft_id = int(request.form.get('nft_id'))
        contract.functions.sendInAuction(nft_id, amount, price).transact({'from': view_account()})
        return redirect('my_nft')
    return render_template('myNFT.html', NFT_list=NFT_list, user=view_account())


if __name__ == '__main__':
    app.run(debug=True)
