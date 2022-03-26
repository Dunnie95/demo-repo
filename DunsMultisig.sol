// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public numConfirmationsRequired;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        mapping(address => bool) isConfirmed;
        uint numConfirmations;
    }

    Transaction[] public transactions;

    constructor(address[] memory _owners, uint _numConfirmationsRequired) public {
       require(_owners.length > 0, "owners required");
       require(
           _numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length,
           "invalid number of required confirmations"
       );

       for (uint i = 0; i < _owners.length; i++) {
           address owner = _owners[i];

           require(owner != address(0), "invalid owner");
           require(!isOwner[owner], "owner not unique");

           isOwner[owner] = true;
           owners.push(owner);
       }  
        
       numConfirmationsRequired = _numConfirmationsRequired;
    }

     function () payable external {
         emit Deposit(msg.sender, msg.value, address(this).balance);
     }

     function deposit() payable external {
         emit Deposit(msg.sender, msg.value, address(this).balance);
     }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _; 
    }

    function SubmitTransaction(address _to, uint _value, bytes memory _data)
        public 
        onlyOwner
        {
            uint txIndex = transactions.length;

            transactions.push(Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed:  false,
                numConfirmations: 0
            }));

            emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
        } 

    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!transactions[_txIndex].isConfirmed[msg.sender], "tx already confirmed");
        _;
    }
        
    function ConfirmTransaction(uint _txIndex)
            public
            onlyOwner
            txExists(_txIndex)
            txExecuted(_txIndex)
            notConfirmed(_txIndex)
            {
                Transaction storage transaction = transactions[_txIndex];

                transaction.isConfirmed[msg.sender] = true;
                transaction.numConfirmations += 1;

                emit ConfirmTransaction(msg.sender, _txIndex);
            }

    function executeTransaction(uint _txIndex)
                public
                onlyOwner
                txExists(_txIndex)
                notExecuted(_txIndex) 
                {
                    Transaction storage transaction = transaction[_txIndex];

                    require(
                        transaction.numConfirmtions >= numConfirmationsRequired,
                        "cannot execute tx"
                    );

                    transaction.executed = true;
                    
                    (bool success, ) = transaction.to.call.value(transaction.value)(transaction.data);
                    require(success, "tx failed");

                    emit ExecuteTransaction(msg.sender, _txIndex);
                }
    function revokeConfirmation(uint _txIndex) 
     public
    onlyOwner
    txExists(_txIndex)
    notExecuted(_txIndex)
{
    Transaction storage transaction = transactions[_txIndex];

    require(transaction.isConfirmed[msg.sender], "tx not confirmed");

    transaction.isConfirmed[msg.sender] = false;
    transaction.numConfirmations -= 1;

    emit RevokeConfirmation(msg.sender, _txIndex);
}


}  