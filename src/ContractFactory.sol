// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./UserCreatedContract.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error InsufficientDEVFee();
error NoTimesetForSendingAssets();

contract ContractFactory is Context, Ownable {
    uint256 public s_devFee; // This is the fee paid to the developer for creating a user contract

    event ContractCreated(address indexed newContract, address indexed creator);

    constructor(uint256 _contractCreationDevFee) Ownable(msg.sender) {
        s_devFee = _contractCreationDevFee; //Developer fee for contract creation
    }

    function createContract(address recipient, uint256 timeToSend, uint256 secondsToAdd)
        external
        payable
        returns (address newContract)
    {
        if (msg.value < s_devFee) revert InsufficientDEVFee();
        //TODO test secondsToAdd and timeToSend cant both be 0
        if (timeToSend == 0 && secondsToAdd == 0) {
            revert NoTimesetForSendingAssets();
        }
        UserCreatedContract userContract = new UserCreatedContract(msg.sender, recipient, timeToSend, secondsToAdd);
        newContract = address(userContract);
        (bool sent,) = owner().call{value: s_devFee}("");
        if (!sent) {
            revert InsufficientDEVFee(); // Revert if the payment to the developer fails
        }
        emit ContractCreated(newContract, msg.sender);
        return newContract;
    }

    //There shouldn't be a need for a maximum requirement in the contract creation fee as safety shouldn't be affected by the fee.
    //If fee is too high, users will not use the service. That would be it.
    function setDevFee(uint256 newFee) external onlyOwner {
        s_devFee = newFee;
    }
}
