// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./IUserCreatedContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error OnlyOwner();



//TODO Have a function that takes the users address and creates a contract for them.
//TODO they will be the "owner" of the contract and can set the address to send the assets to. This can also bedone on creation
//TODO get the amount of link needed for the contract creation and gas fees.
//TODO they can also set the number of assets to send.
//TODO use chainlink keepers to automate the sending of assets after a certain time has passed.
//TODO helper function to determine needed gas fees for the contract creation and sending of assets. (in link)
//TODO they can also set the time to send the assets. or how long they can be inactive before the assets are sent. to the address/es
//TODO on contract creation give an option to either allow pulling of assets or no pulling of assets.
//TODO for every new asset added to the contract (except ETH), the contract will need more funding of ETH to cover the gas fees. and there's a genral fee for the contract creation for dev.

contract UserCreatedContract is IUserCreatedContract {
    address public s_owner; // The owner of the contract, who can set the recipient and other parameters
    address public s_recipient; // The address to which the assets will be sent //TODO make this multiple addresses
    address public s_contractCreationDevAddress; // The address of the developer for payment of the contract creation dev fee
    uint256 public s_timeToSend;
    uint256 public s_contractCreationTime; // The timestamp for when the contract was created
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
        isPullingAllowed = _isPullingAllowed;
    }

    function getRecipient() external view returns (address);
    function getTimeToSend() external view returns (uint256 timeLeftSecs, uint256 timestamp); // can have both or one of them

    function getIsPullingAllowed() public view returns (bool) {
        return s_isPullingAllowed;
    }
    function getOwner() external view returns (address);
    function getContractAddress() external view returns (address);
    function getERC20Balances(address[] calldata tokenAddresses) external view returns (uint256[] memory);
    function getERC721Balances(address[] calldata tokenAddresses) external view returns (uint256[] memory);
    function getERC1155Balances(address[] calldata tokenAddresses) external view returns (uint256[] memory);
    function getETHBalance() external view returns (uint256);

    function getContractCreationTime() external view returns (uint256) {
        return s_contractCreationTime;
    }

    function getContractCreationDevFee() external view returns (uint256) {
        return s_contractCreationDevFee;
    }

    function calculateSendFee() external view returns (uint256) {
        // This function should calculate the gas fee (chainlink keepers and native token gas) required to send the assets
        return s_contractSendGasFee;
    }

    function getOwner() external view returns (address) {
        return s_owner;
    }

    function getRecipient() external view returns (address) {
        return s_recipient;
    }

    function getTimeToSend() external view returns (uint256 timeLeftSecs, uint256 timestamp) {
        uint256 timeLeft = s_timeToSend > block.timestamp ? s_timeToSend - block.timestamp : 0;
        return (timeLeft, s_timeToSend);
    }

    function getERC20Balances(address[] calldata tokenAddresses) external view override returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](tokenAddresses.length);
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            balances[i] = IERC20(tokenAddresses[i]).balanceOf(address(this));
        }
        return balances;
    }

    function getContractCreationDevAddress() external view returns (address); // Found in the contract factory variable

    function setRecipient(address recipient) external {
        if (msg.sender != owner) revert OnlyOwner(); // Only the owner of the contract can set the recipient
        s_recipient = recipient;
    }

    function setTimeToSend(uint256 timeLeftSecs, uint256 timestamp) external;

    
}
