// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./UserCreatedContract.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error InsufficientDEVFee();

contract ContractFactory is Context, Ownable {
    address public s_owner;
    uint256 public s_contractCreationDevFee; // This is the fee paid to the developer for creating a user contract

    event ContractCreated(address indexed newContract, address indexed creator);

    constructor(uint256 _contractCreationFee, uint256 _contractCreationGasFee, uint256 _contractCreationDevFee) {
        s_owner = msg.sender;
        s_contractCreationDevFee = _contractCreationDevFee; //Developer fee for contract creation
    }

    function createContract(address recipient, uint256 timeToSend, bool isPullingAllowed)
        external
        payable
        returns (address newContract)
    {
        if (msg.value < s_contractCreationDevFee) revert InsufficientDEVFee();

        newContract = address(new UserCreatedContract(msg.sender, recipient, timeToSend, isPullingAllowed));

        emit ContractCreated(newContract, msg.sender);
    }

    function getContractCreationDevFee() public view returns (uint256) {
        return s_contractCreationDevFee;
    }

    //There shouldn't be a need for a maximum requirement in the contract creation fee as safety shouldn't be affected by the fee.
    //If fee is too high, users will not use the service. That would be it.
    function setContractCreationDevFee(uint256 newFee) external onlyOwner {
        s_contractCreationDevFee = newFee;
    }
}
