// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4 ;

import {ERC20}  from "./ERC20.sol";
import {ERC1155}  from "./ERC1155.sol";

contract app {

    myToken public Token;
    MyNFT public NFT;

    address myContract = address(this);

    struct User{
        string name;
        string password;
    }
    struct Transfer{
        uint id;
        address sender;
        address recipient;
        uint sum;
        bool status;
        string currency;
    }
    struct Nft{
        address owner;
        uint id;
        string name;
        string picture;
        uint amount;
        bool inAuction;
        bool inCollection;
        //
        // string data;
    }
    // struct NftCollection{
    //     uint id;
    // }

    Nft[] public arrayNft;
    address[] public accounts;
    Transfer[] public transfers;


    mapping (address => User) public users;
    // mapping (address => mapping (uint => Nft)) public nftSender;

    constructor(){
        Token = new myToken (myContract, 100000);
        NFT = new MyNFT();
    }

    // Creating functions registration

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

    // Creating functions transaction

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

    // Creating functions mytoken

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

    //Creting functions NFT

    function createNft (string memory _name, string memory _picture, uint _amount, string memory _data) public {
        NFT.mint(msg.sender, arrayNft.length, _amount, _data);
        // nftSender[msg.sender][arrayNft.length] = Nft(msg.sender, arrayNft.length, _name, _picture, _amount, false, false);
        arrayNft.push(Nft(msg.sender, arrayNft.length, _name, _picture, _amount, false, false));
    }

    function getBalanceNft(uint _id) public view returns(uint){
        return NFT.balanceOf(msg.sender, _id);
    }

    function getArrayNFT() public view returns(Nft[] memory){
        return arrayNft;
    }

    function sendInAuction(uint _id, uint _amount, string memory _data) public{
        // require(getBalanceNft(_id) >= _amount, "not enough tokens");
        // require(_amount > 0, "It is impossible to issue 0 tokens");
        NFT.transferNft(msg.sender, myContract, _id, _amount, _data);
        arrayNft[_id].inAuction = true;
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

contract MyNFT is ERC1155(""){
    function mint(address _owner, uint _id, uint _value, string memory _data) public {
        _mint(_owner, _id, _value, bytes(_data));
    }
    function transferNft(address _sender, address _to, uint _id, uint _amount, string memory _data) public {
        safeTransferFrom(_sender, _to, _id, _amount, bytes(_data));
    }
}