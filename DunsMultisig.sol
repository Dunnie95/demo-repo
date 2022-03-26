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

  //  mapping(uint => Transaction) transactionList;

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

    fallback () payable external {
         emit Deposit(msg.sender, msg.value, address(this).balance);
     }

     function deposit() payable external {
         emit Deposit(msg.sender, msg.value, address(this).balance);
     }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _; 
    }

    function SubmitTrans(address _to, uint _value, bytes memory _data) public onlyOwner{
        uint txIndex = transactions.length;
        Transaction storage newTransaction;
        newTransaction.to;
        newTransaction.value;
        newTransaction.data;
        newTransaction.executed;
        newTransaction.isConfirmed;
        newTransaction.numConfirmations;
        transactions.push(newTransaction);

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
        } 

    modifier notExists(uint _txIndex) {
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
        
    function ConfirmTrans(uint _txIndex)
            public
            onlyOwner
            notExists(_txIndex)
            notExecuted(_txIndex)
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
                notExists(_txIndex)
                notExecuted(_txIndex) 
                {
                    Transaction storage transaction = transactions[_txIndex];

                    require(
                        transaction.numConfirmations >= numConfirmationsRequired,
                        "cannot execute tx"
                    );

                    transaction.executed = true;
                    
                    (bool success) = transaction{value, data};
                    require(success, "tx failed");
                    emit ExecuteTransaction(msg.sender, _txIndex);
                }
    function revokeConfirmation(uint _txIndex) 
     public
    onlyOwner
    notExists(_txIndex)
    notExecuted(_txIndex)
{
    Transaction storage transaction = transactions[_txIndex];

    require(transaction.isConfirmed[msg.sender], "tx not confirmed");

    transaction.isConfirmed[msg.sender] = false;
    transaction.numConfirmations -= 1;

    emit RevokeConfirmation(msg.sender, _txIndex);
}


}