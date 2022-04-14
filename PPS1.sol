//function
//struct
//array
//events
//uint
//string
//contract statement
//mapping
//prama statement
//modifiers
//license modifier
//interface

//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.6.0;

contract ZombieFactory {
    uint dnaDigit = 16;

// string name

    struct Zombie {
        string name;
        uint dnaDigit;
    }

    Zombie[] public zombies;

    event newZombie
    (string name);

    functions createZombie (string memory _name, uint _dnaDigit) public{
        zombies.push(Zombie(_name, _dnadigit));
        emit newZombie(_name)
    }
}