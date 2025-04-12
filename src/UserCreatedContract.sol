// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./IUserCreatedContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


error OnlyOwner();
error 

contract UserCreatedContract is IUserCreatedContract {
    address public s_owner; // The owner of the contract, who can set the recipient and other parameters
    address public s_recipient; // The address to which the assets will be sent //TODO make this multiple addresses
    address public s_contractCreationDevAddress; // The address of the developer for payment of the contract creation dev fee
    uint256 public s_timeToSend;
    uint256 public s_contractCreationTime; // The timestamp for when the contract was created
    uint256 public s_contractCreationDevFee; // This is the fee paid to the developer for creating the contract
    uint256 public s_contractSendGasFee; // This is the gas fee for sending assets 

    bool public s_isPullingAllowed; // This determines if the contract allows pulling of assets or not

    constructor(
        address _recipient,
        uint256 _timeToSend,
        bool _isPullingAllowed,
        uint256 _contractCreationDevFee,
        address _contractCreationDevAddress
    ) {
        owner = msg.sender;
        recipient = _recipient;
        timeToSend = _timeToSend;
        contractCreationTime = block.timestamp;
        contractCreationDevFee = _contractCreationDevFee;
        contractCreationDevAddress = _contractCreationDevAddress;
        isPullingAllowed = _isPullingAllowed;
    }

    function getRecipient () external view returns (address);
    function getTimeToSend () external view returns (uint256 timeLeftSecs , uint256 timestamp); // can have both or one of them
    function getIsPullingAllowed () external view returns (bool);
    function getOwner () external view returns (address);
    function getContractAddress () external view returns (address);
    function getERC20Balances(address[] calldata tokenAddresses) external view returns (uint256[] memory);
    function getERC721Balances(address[] calldata tokenAddresses) external view returns (uint256[] memory);
    function getERC1155Balances(address[] calldata tokenAddresses) external view returns (uint256[] memory);
    function getETHBalance () external view returns (uint256);

    function getContractCreationTime () external view returns (uint256) {
        return s_contractCreationTime;
    }

    function getContractCreationDevFee () external view returns (uint256) {
        return s_contractCreationDevFee;
    }

    function calculateGasFeeToSend() external view returns (uint256) {
        // This function should calculate the gas fee required to send the assets
        // For simplicity, we can return a fixed value or implement a more complex calculation
        // In a real-world scenario, this would involve estimating gas costs based on current network conditions
        return s_contractSendGasFee;
    }

    function getOwner () external view returns (address) {
        return s_owner;
    }

    function getRecipient () external view returns (address) {
        return s_recipient;
    }

    function getTimeToSend () external view returns (uint256 timeLeftSecs, uint256 timestamp) {
        uint256 timeLeft = s_timeToSend > block.timestamp ? s_timeToSend - block.timestamp : 0;
        return (timeLeft, s_timeToSend);
    }

    function getContractCreationDevAddress () external view returns (address); // Found in the contract factory variable

    function setRecipient (address recipient) external {
        if (msg.sender != owner) revert OnlyOwner(); // Only the owner can set the recipient
        require(msg.sender == owner, ); 
        require(recipient != address(0), "Invalid recipient address");
        this.recipient = recipient;
    }
    function setTimeToSend (uint256 timeLeftSecs, uint256 timestamp) external;

    function getERC20Balances(address[] calldata tokenAddresses) external view override returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](tokenAddresses.length);
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            balances[i] = IERC20(tokenAddresses[i]).balanceOf(address(this));
        }
        return balances;
    }

   
        }