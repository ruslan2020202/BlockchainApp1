// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4 ;

import {ERC20}  from "./ERC20.sol";

contract app {

    struct User{
        string name;
        string password;
    }

    address[] public accounts;
    mapping (address => User) public users;
    myToken public Token;
    address myContract = address(this);

    constructor(){
        Token = new myToken (myContract, 100000);
    }


    function signup(string memory _name, string memory _password) public {
        for(uint i = 0; i < accounts.length; i++){
            require(accounts[i] != msg.sender, "User found");
        }
        accounts.push(msg.sender);
        users[msg.sender] = User(_name, _password);
        Token.toTransfer(myContract, msg.sender, 1000);
    }


    function login(address _account, string memory _password) public view{
            require(keccak256(abi.encode(users[_account].password)) == keccak256(abi.encode(_password)), "Failed");
    }

    function getAccounts() public view returns (address[] memory){
        return accounts;
    }

    function getInformation(address _account) public view returns (string memory){
        return users[_account].name;
    }


    struct Transfer{
        uint id;
        address sender;
        address recipient;
        uint sum;
        bool status;
        string currency;
    }

    Transfer[] public transfers;

    function sendToTransfer (address _recipient) public payable {
        require(msg.value > 0, "Not money");
        require(msg.sender != _recipient, "Can't send to yourself");
        transfers.push(Transfer(transfers.length, msg.sender, _recipient, msg.value, false, "ETH"));
    }

    function getTransfers () public view returns (Transfer[] memory){
        return transfers;

    }
    function getTotransfer(uint _id) public payable {
        require(transfers.length > _id, "There is no such transfer");
        require(transfers[_id].status == false, "Transfer is completed" );
        require(transfers[_id].recipient == msg.sender, "Not the recipient");
        payable(transfers[_id].recipient).transfer(transfers[_id].sum);
        transfers[_id].status = true;
    }

    function getBalanceToken() public view returns (uint){
        return Token.balanceOf(msg.sender);
    }
    function sendTransferToken(address _to, uint _value) public {
        // require(Token.balanceOf(msg.sender) >= _value, "Insufficient funds");
        Token.toTransfer(msg.sender, _to, _value);
        transfers.push(Transfer(transfers.length, msg.sender, _to, _value, true, "FR"));
    }

    function getBalanceContract() public view returns(uint){
        return Token.balanceOf(myContract);
    }

}

contract myToken is ERC20("Faer", "FR"){
    constructor(address account, uint amount) {
        _mint(account, amount);
    }

    function toTransfer(address _sender, address _to, uint _amount) public {
        _transfer(_sender, _to, _amount);
    }
}

