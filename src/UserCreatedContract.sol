// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error OnlyOwner();
error InvalidTimestamp();
error CountdownTimerNotResettable();

//TODO calculate the amount of link needed for the contract creation and gas fees.
//TODO they can also set the number of assets to send.
//TODO use chainlink keepers to automate the sending of assets after a certain time has passed.
//TODO helper function to determine needed gas fees for the contract creation and sending of assets. (in link)
//TODO they can also set the time to send the assets. or how long they can be inactive before the assets are sent. to the address/es
//TODO for every new asset added to the contract (except ETH), the contract will need more funding of ETH to cover the gas fees. and there's a genral fee for the contract creation for dev.
//TODO update to allow mutiple owners to set the recipients and other parameters.

contract UserCreatedContract {
    uint256 public immutable s_secsToAdd; // The number of seconds to add to the countdown timer when assets are sent (only if the countdown timer is used and can only be set during contract creation. If no secs default to 0)

    address public s_owner; // The owner of the contract, who can set the recipient and other parameters
    address public s_recipient; // The address to which the assets will be sent //TODO make this multiple addresses
    uint256[2] public s_timesToSend; // Array of two timestamps: [countdown timer, timestamp to send assets]. Both can be used or only one. Once set in contract creation the timestamp can not be changed.
    uint256 public s_contractCreationTime; // The timestamp for when the contract was created
    uint256 public s_timeToSend; // The earliest time when the assets can be sent

    /**
     * @dev Throws if called by any account other than the owner.
     */
    //TODO test this modifier
    modifier onlyOwner() {
        if (msg.sender != s_owner) revert OnlyOwner();
        _;
    }

    constructor(
        address _owner,
        address _recipient,
        uint256 _timeToSend,
        uint256 _secsToAdd // The number of seconds to add to the countdown timer when assets are sent
    ) {
        s_owner = _owner;
        s_recipient = _recipient;
        s_contractCreationTime = block.timestamp;
        s_secsToAdd = _secsToAdd; // If set to 0, the countdown timer will not be used and the user must use the timestamp to send assets
        s_timesToSend = [_secsToAdd, _timeToSend]; // Initialize with the provided countdown timer and a default timestamp
    }

    // Owner of the contract can reset the time to send assets in a manner of a countdown timer
    function resetCountdownTimerToSend() external onlyOwner {
        uint256 countdownTimer = s_timesToSend[0];
        uint256 timestampToSend = s_timesToSend[1];

        if (countdownTimer == 0 || s_secsToAdd == 0) {
            // Timer expired, we can't reset the countdown timer
            //OR
            // If secs to add is 0, we can't reset the countdown timer
            // User should set the secs to add during contract creation
            revert CountdownTimerNotResettable();
        }

        s_timesToSend[0] = s_secsToAdd; // Reset the countdown timer
        // Find the earliest time to send the assets in s_timesToSend array and sets its value as s_timeToSend
        (countdownTimer < timestampToSend - block.timestamp)
            ? s_timeToSend = block.timestamp + countdownTimer
            : s_timeToSend = block.timestamp + timestampToSend;
    }

    // function getContractAddress() external view returns (address);
    // function getERC20Balances(address[] calldata tokenAddresses) external view returns (uint256[] memory);
    // function getERC721Balances(address[] calldata tokenAddresses) external view returns (uint256[] memory);
    // function getERC1155Balances(address[] calldata tokenAddresses) external view returns (uint256[] memory);
    // function getETHBalance() external view returns (uint256);

    function calculateSendFee() public pure returns (uint256) {
        // This function should calculate the gas fee (chainlink keepers and native token gas) required to send the assets
        uint256 fee = 0;
        return fee;
    }

    function getERC20Balances(address[] calldata tokenAddresses) public view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](tokenAddresses.length);
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            balances[i] = IERC20(tokenAddresses[i]).balanceOf(address(this));
        }
        return balances;
    }
}
