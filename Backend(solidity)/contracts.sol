// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4 ;

import {ERC20}  from "./ERC20.sol";
import {ERC1155}  from "./ERC1155.sol";

contract app {

    myToken public Token;
    MyNFT public NFT;

    address public myContract = address(this);

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
        uint id;
        string name;
        string picture;
    }

    struct nftUser{
        uint idNftUser;
        address owner;
        uint idNft;
        uint amount;
        bool inAuction;
        bool inCollection;
    }

    struct nftTransfer{
        uint id;
        uint idNftUser;
        address owner;
        uint amount;
        uint price;
        bool status;
        uint256 start;
        uint256 end;
        address recipient;
        uint bid;
    }

    nftUser[] public arrayNftUser;
    Nft[] public nftArray;
    nftTransfer[] public nftTransfers;
    address[] public accounts;
    Transfer[] public transfers;



    mapping (address => User) public users;
    // mapping (address => mapping (uint => Nft)) public nftSender;

    constructor(){
        Token = new myToken (myContract, 100000);
        NFT = new MyNFT();
        signup("ruslan", "123");
        createNft("m0nkeyNFT", "monkey0.png", 10);
        // createNft("m0nkeyNFTBlue", "monkey1.png", 7);
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

    function sendTransferTokenRecipient(address _owner, address _recipient, uint _value) public{
        Token.toTransfer(_owner, _recipient, _value);
        transfers.push(Transfer(transfers.length, _owner, _recipient, _value, true, "FR"));
    }

    function getBalanceContract() public view returns(uint){
        return Token.balanceOf(myContract);
    }

    //Creting functions NFT

    function createNft (string memory _name, string memory _picture, uint _amount) public {
        NFT.mint(msg.sender, nftArray.length, _amount);
        nftArray.push(Nft(nftArray.length, _name, _picture));
        arrayNftUser.push(nftUser(arrayNftUser.length, msg.sender, nftArray.length - 1, _amount, false, false));
    }

    function getBalanceNft(uint _id) public view returns(uint){
        return NFT.balanceOf(msg.sender, _id);
    }

    function getbalanceNftOwner(address _owner, uint _id) public view returns(uint){
        return NFT.balanceOf(_owner, _id);
    }

    function getArrayNFT() public view returns(Nft[] memory){
        // 0,m0nkeyNFT,monkey0.png
        return nftArray;
    }

    function getUserNft() public view returns(nftUser[] memory){
        // 0,0x7B2f5243C7E300803eb2D00577Fd8516968a4501,0,10,false,false
        return arrayNftUser;
    }

    function getNftTransfers() public view returns(nftTransfer[] memory){
        return nftTransfers;
    }





    function sendInAuction(uint _id, uint _amount, uint _price, uint _minutes) public{ //In parametrs Id UserNFT
        require(getBalanceNft(arrayNftUser[_id].idNft) >= _amount, "not enough tokens");
        require(_amount > 0, "It is impossible to issue 0 tokens");
        require(arrayNftUser[_id].inAuction == false, "nft is already at auction");
        require(arrayNftUser[_id].inCollection == false, "nft in collection");
        arrayNftUser[_id].inAuction = true;
        uint start = block.timestamp;
        nftTransfers.push(nftTransfer(nftTransfers.length, _id, msg.sender, _amount,
        _price, true, start, start + _minutes*60, msg.sender, 0));
    }

    function placeBet(uint _id, uint _bet, uint256 _time) public{ //In parametrs Id Transfer
        require(_id < nftTransfers.length, "there is no such transfer" );
        require(nftTransfers[_id].owner != msg.sender, "you can't buy your own nft");
        require(nftTransfers[_id].status == true, "there is no such transfer");
        require(getBalanceToken() >= nftTransfers[_id].amount, "not enough funds to buy");
        require(nftTransfers[_id].end > _time, "auction time is out");
        require(nftTransfers[_id].bid < _bet, "your bid must be greater than the previous one");
        if (nftTransfers[_id].bid > 0){
            sendTransferTokenRecipient(myContract, nftTransfers[_id].recipient, nftTransfers[_id].bid);
        }
        sendTransferToken(myContract, _bet);
        nftTransfers[_id].recipient = msg.sender;
        nftTransfers[_id].bid = _bet;

    }

    function checkNFT(uint _id, address _recipient) private view returns (int){
        int indexNft = -1;
        for (uint i = 0; i < arrayNftUser.length; i++ ){
            if (arrayNftUser[i].idNft == _id && arrayNftUser[i].owner == _recipient ){
                return int(i);
            }
        }
        return indexNft;
    }

    function buyNft(uint _id, uint _time) public{ //In parametrs Id Transfer
        require(nftTransfers[_id].end < _time, "nft still at auction");
        require(nftTransfers[_id].status == true, "there is no such transfer");
        if (nftTransfers[_id].price < nftTransfers[_id].bid){
            sendTransferTokenRecipient(myContract, nftTransfers[_id].owner, nftTransfers[_id].bid);
            NFT.transferNft(nftTransfers[_id].owner, nftTransfers[_id].recipient, arrayNftUser[nftTransfers[_id].idNftUser].idNft , nftTransfers[_id].amount);
            int check = checkNFT(arrayNftUser[nftTransfers[_id].idNftUser].idNft, nftTransfers[_id].recipient);
            if (check >= 0){
                arrayNftUser[uint(check)].amount += nftTransfers[_id].amount;
            }else {
                arrayNftUser.push(nftUser(arrayNftUser.length, nftTransfers[_id].recipient, arrayNftUser[nftTransfers[_id].idNftUser].idNft, nftTransfers[_id].amount, false, false ));
            }
        }
        arrayNftUser[nftTransfers[_id].idNftUser].amount = getbalanceNftOwner(nftTransfers[_id].owner, arrayNftUser[nftTransfers[_id].idNftUser].idNft);
        arrayNftUser[nftTransfers[_id].idNftUser].inAuction = false;
        nftTransfers[_id].status = false;
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
    function mint(address _owner, uint _id, uint _value) public {
        _mint(_owner, _id, _value, "");
    }
    function transferNft(address _sender, address _to, uint _id, uint _amount) public {
        _safeTransferFrom(_sender, _to, _id, _amount, "");
    }
}