// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./IUserCreatedContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


error OnlyOwner();
error 

contract UserCreatedContract is IUserCreatedContract {
    address public owner;
    address public recipient;
    uint256 public timeToSend;
    uint256 public contractCreationTime;
    uint256 public contractCreationFee;
    uint256 public contractCreationGasFee;
    uint256 public contractCreationDevFee;
    address public contractCreationDevAddress;
    bool public isPullingAllowed;

    constructor(
        address _recipient,
        uint256 _timeToSend,
        bool _isPullingAllowed,
        uint256 _contractCreationFee,
        uint256 _contractCreationGasFee,
        uint256 _contractCreationDevFee,
        address _contractCreationDevAddress
    ) {
        owner = msg.sender;
        recipient = _recipient;
        timeToSend = _timeToSend;
        contractCreationTime = block.timestamp;
        contractCreationFee = _contractCreationFee;
        contractCreationGasFee = _contractCreationGasFee;
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
    function getContractCreationTime () external view returns (uint256);
    function getContractCreationFee () external view returns (uint256);
    function getContractCreationGasFee () external view returns (uint256);
    function getContractCreationDevFee () external view returns (uint256);
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