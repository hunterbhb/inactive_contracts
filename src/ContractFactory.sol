// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./IUserCreatedContract.sol";
import "./UserCreatedContract.sol";

error InsufficientDEVFee();

contract ContractFactory {
    address public s_owner;
    uint256 public s_contractCreationDevFee;

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

        newContract = address(new UserCreatedContract(recipient, timeToSend, isPullingAllowed));

        emit ContractCreated(newContract, msg.sender);
    }

    function getOwner() public view returns (address) {
        return s_owner;
    }

    function getContractCreationDevFee() public view returns (uint256) {
        return s_contractCreationDevFee;
    }

    //Helper function to get the gas fee in Link to automate the Keepers
    function getGasFeeInLink() public view returns (uint256) {}
    //There shouldn't be a need for a maximum requirement in the contract creation fee as safety shouldn't be affected by the fee.
    //If fee is too high, users will not use the service. That would be it.

    function setContractCreationDevFee(uint256 newFee) external {
        require(msg.sender == s_owner, "Only owner can set the fee");
        s_contractCreationDevFee = newFee;
    }
}
