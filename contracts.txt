// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4 ;

contract app {

    struct User{
        string name;
        string password;
    }

    address[] public accounts;
    mapping (address => User) public users;


    function signup(address _account, string memory _name, string memory _password) public {
        for(uint i = 0; i < accounts.length; i++){
            require(accounts[i] != _account, "User found");
        }
        accounts.push(_account);
        users[_account] = User(_name, _password);
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
    }

    Transfer[] public transfers;

    function sendToTransfer (address _recipient) public payable {
        require(msg.value > 0, "Not money");
        require(msg.sender != _recipient, "Can't send to yourself");
        transfers.push(Transfer(transfers.length, msg.sender, _recipient, msg.value, false));
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


}