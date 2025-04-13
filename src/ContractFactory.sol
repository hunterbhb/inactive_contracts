// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./UserCreatedContract.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error InsufficientDEVFee();

contract ContractFactory is Context, Ownable {
    uint256 public s_devFee; // This is the fee paid to the developer for creating a user contract
    address public s_devAddress; // The address of the developer for payment of the contract creation dev fee

    event ContractCreated(address indexed newContract, address indexed creator);

    constructor(uint256 _contractCreationDevFee) {
        s_devFee = _contractCreationDevFee; //Developer fee for contract creation
        s_devAddress = msg.sender; // Set the contract creator as the dev address
    }

    function createContract(address recipient, uint256 timeToSend, bool isPullingAllowed)
        external
        payable
        returns (address newContract)
    {
        if (msg.value < s_devFee) revert InsufficientDEVFee();

        newContract =
            address(new UserCreatedContract(recipient, timeToSend, isPullingAllowed));
        (bool sent,) = s_devAddress.call{value: s_devFee}("");
        emit ContractCreated(newContract, msg.sender);
    }

    //There shouldn't be a need for a maximum requirement in the contract creation fee as safety shouldn't be affected by the fee.
    //If fee is too high, users will not use the service. That would be it.
    function setDevFee(uint256 newFee) external onlyOwner {
        s_devFee = newFee;
    }

    function setDevAddress(address newAddress) external onlyOwner {
        s_devAddress = newAddress;
    }
}
