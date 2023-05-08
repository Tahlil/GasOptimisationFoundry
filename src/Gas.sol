// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

contract GasContract {
    uint256 public totalSupply = 0; // cannot be updated
    mapping(address => uint256) public balances;

    mapping(address => uint256) public whitelist;
    address[5] public administrators;
    
    struct ImportantStruct {
        uint256 amount;
        uint16 valueB; // max 3 digits
        uint16 valueA; // max 3 digits
        uint256 bigValue;
        bool paymentStatus;
        address sender;
    }
    mapping(address => ImportantStruct) public whiteListStruct;

    event AddedToWhitelist(address userAddress, uint256 tier);

    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        totalSupply = _totalSupply;

        for (uint256 ii = 0; ii < administrators.length; ii++) {
            if (_admins[ii] != address(0)) {
                administrators[ii] = _admins[ii];
                if (_admins[ii] == msg.sender) {
                    balances[msg.sender] = totalSupply;
                }
            }
        }
    }

    function checkForAdmin(address _user) public view returns (bool admin_) {
        bool admin = false;
        for (uint256 ii = 0; ii < administrators.length; ii++) {
            if (administrators[ii] == _user) {
                admin = true;
            }
        }
        return admin;
    }
    

    function balanceOf(address _user) external view returns (uint256 balance_) {
        uint256 balance = balances[_user];
        return balance;
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) external returns (bool status_) {
        if(balances[msg.sender] < _amount || bytes(_name).length >= 9) revert();
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        return true;
    }

    function addToWhitelist(address _userAddrs, uint256 _tier)
        public     
    {
        if(!checkForAdmin(msg.sender) || _tier > 254) revert();
        whitelist[_userAddrs] = _tier;
        if (_tier > 3) {
            whitelist[_userAddrs] = 3;
        }
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public {
        uint256 usersTier = whitelist[msg.sender];
        if(usersTier > 4 || usersTier == 0 ) revert();
        whiteListStruct[msg.sender] = ImportantStruct(_amount, 0, 0, 0, true, msg.sender);
        if (balances[msg.sender] < _amount || _amount < 4) revert();
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        balances[msg.sender] += whitelist[msg.sender];
        balances[_recipient] -= whitelist[msg.sender];
        
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public returns (bool, uint256) {        
        return (whiteListStruct[sender].paymentStatus, whiteListStruct[sender].amount);
    }

}