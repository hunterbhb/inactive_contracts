// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

error OnlyOwner();
error InvalidTimestamp();
error CountdownTimerNotResettable();

//Support for only erc20, erc721, erc1155 and native assets (ETH) at the moment
contract UserCreatedContract {
    uint256 public immutable s_secsToAdd; // The number of seconds to add to the countdown timer when assets are sent (only if the countdown timer is used and can only be set during contract creation. If no secs default to 0)

    address public s_owner; // The owner of the contract, who can set the recipient and other parameters
    address public s_recipient; // The address to which the assets will be sent
    address[] public s_tokenAddresses; // Array to store token addresses to be sent later
    uint256[2] public s_timesToSend; // Array of two timestamps: [countdown timer, timestamp to send assets]. Both can be used or only one. Once set in contract creation the timestamp can not be changed.
    uint256 public s_contractCreationTime; // The timestamp for when the contract was created
    uint256 public s_timeToSend; // The earliest time when the assets can be sent

    mapping(address => bool) public s_tokenAddressTracker; // Mapping to track if a token address is already added
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
        address[] memory _tokenAddresses,
        uint256 _secsToAdd // The number of seconds to add to the countdown timer when assets are sent
    ) {
        s_owner = _owner;
        s_recipient = _recipient;
        s_contractCreationTime = block.timestamp;
        s_secsToAdd = _secsToAdd; // If set to 0, the countdown timer will not be used and the user must use the timestamp to send assets
        s_tokenAddresses = _tokenAddresses; // Init array of token addresses to be sent later
        s_timesToSend = [_secsToAdd, _timeToSend]; // Initialize with the provided countdown timer and a default timestamp
    }

    // Owner of the contract can reset the time to send assets in a manner of a countdown timer
    function resetCountdownTimerToSend() external onlyOwner {
        uint256 countdownTimer = s_timesToSend[0];
        uint256 timestampToSend = s_timesToSend[1];

        if (countdownTimer == 0 || s_secsToAdd == 0) {
            // Timer expired, we can't reset the countdown timer
            // OR
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
    //TODO finish this function

    function calculateSendFee() public pure returns (uint256) {
        // This function should calculate the gas fee (chainlink keepers and native token gas) required to send the assets
        uint256 fee = 0;
        return fee;
    }

    // Anyone send assets to the this contract, but only the owner can add the assets to be sent later when timer has been reached.
    // After the initial assests have been sent, even at a later time, the owner can manually send "forgotten" assets to the recipient address.
    // (A case where the owner forgot to add the assets to be sent or assets gained value after timer expired etc.)
    // Token type will be tracked by the index database of the token address in the s_tokenAddresses array.
    function addAssetsToSend(address[] calldata tokenAddresses) external onlyOwner {
        for (uint256 i = 0; i < s_tokenAddresses.length; i++) {
            if (s_tokenAddressTracker[tokenAddresses[i]] = true) {
                continue; // Skip if the token address is already added (Frontend will also check this with indexing)
            }
            s_tokenAddresses.push(tokenAddresses[i]); // Add the token address to the array for sending logic
            s_tokenAddressTracker[tokenAddresses[i]] = true; // Mark the token address as added
        }
    }
    // This function will be called by the user to deposit assets to the contract
    // Assests can also be sent to the contract by anyone, but only the owner can add them to the s_tokenAddresses array. This function is more of a helper function to make it easier for the user to deposit assets and directly track.
    //TODO save the token type of the deposited asset to the contract to? Chainlink keepers will need to know the token type to send the assets.

    function depositTokenAssets(
        address tokenAddress,
        string memory tokenType,
        uint256 tokenIdOrAmount,
        uint256 amountForERC1155
    ) external onlyOwner {
        if (keccak256(abi.encodePacked(tokenType)) == keccak256(abi.encodePacked("ERC20"))) {
            IERC20 token = IERC20(tokenAddress);
            token.transferFrom(msg.sender, address(this), tokenIdOrAmount);
        } else if (keccak256(abi.encodePacked(tokenType)) == keccak256(abi.encodePacked("ERC721"))) {
            IERC721 token = IERC721(tokenAddress);
            token.safeTransferFrom(msg.sender, address(this), tokenIdOrAmount);
        } else if (keccak256(abi.encodePacked(tokenType)) == keccak256(abi.encodePacked("ERC1155"))) {
            IERC1155 token = IERC1155(tokenAddress);
            token.safeTransferFrom(msg.sender, address(this), tokenIdOrAmount, amountForERC1155, "");
        } else {
            revert("Invalid asset type");
        }
        if (s_tokenAddressTracker[tokenAddress] == false) {
            s_tokenAddresses.push(tokenAddress); // Add the token address to the array for sending logic
            s_tokenAddressTracker[tokenAddress] = true; // Mark the token address as added
        }
    }
    //Native assets (ETH) will always be sent to the recipient address
    //TODO function to send assets to the recipient address (pops form the s_tokenAddresses array) and sets the s_tokenAddressTracker to false (callable by anyone but should be called by chainlink keepers)
}
