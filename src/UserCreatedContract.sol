// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@chainlink/lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

error OnlyOwner();
error InvalidTimestamp();
error CountdownTimerNotResettable();

//Support for only erc20, erc721, erc1155 and native assets (ETH) at the moment
//TODO add support for more token standards but start with eth native the entire process
//TODO Manual send as a just in case function
contract UserCreatedContract is AutomationCompatibleInterface {
    uint256 public immutable s_secsToAdd; // The number of seconds to add to the countdown timer for when assets are sent

    address public s_owner; // The owner of the contract, who can set the recipient and other parameters
    address public s_recipient; // The address to which the assets will be sent
    address[] public s_tokenAddresses; // Array to store token addresses to be sent later
    uint256 public s_contractCreationTime; // The timestamp for when the contract was created
    uint256 public s_timeToSend; // Time when the assets can be sent

    mapping(address => bool) public s_tokenAddressTracker; // Mapping to track if a token address is already added


    event ETHSent(address indexed to, uint256 amount);
    /**
     * @dev Throws if called by any account other than the owner.
     */
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
        s_tokenAddresses = _tokenAddresses; // Init array of token addresses to be sent later
        s_timeToSend = _timeToSend;
        s_secsToAdd = _secsToAdd; // Must be non-zero to allow countdown timer resets

    }

    receive() external payable { 
        
    }

    // Chainlink Keepers function: Check if upkeep is needed
    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = (block.timestamp >= s_timeToSend && address(this).balance > 0);
    }

    // Chainlink Keepers function: Perform the upkeep
    function performUpkeep(bytes calldata) external override {
        if (isExpiredLock() == false) {
            revert InvalidTimestamp();

        }
        require(block.timestamp >= s_timeToSend, "Time to send ETH has not been reached");
        require(address(this).balance > 0, "No ETH to send");


        (bool success, ) = s_recipient.call{value: address(this).balance}("");
        require(success, "Failed to send ETH");

        emit ETHSent(s_recipient, address(this).balance);
    }

    // Owner of the contract can reset the time to send assets in a manner of a countdown timer
    function resetCountdownTimerToSend() external onlyOwner {
        if (s_secsToAdd == 0) {
            revert CountdownTimerNotResettable();
        }
        s_timeToSend = block.timestamp + s_secsToAdd;
    }

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

    function isExpiredLock() public view returns (bool) {
        return block.timestamp >= s_timeToSend;
    }

    // This function will be called by the user to deposit assets to the contract
    // Assests can also be sent to the contract by anyone, but only the owner can add them to the s_tokenAddresses array. This function is more of a helper function to make it easier for the user to deposit assets and directly track.
    //TODO save the token type of the deposited asset to the contract to? Chainlink keepers will need to know the token type to send the assets.

    // function depositTokenAssets(
    //     address tokenAddress,
    //     string memory tokenType,
    //     uint256 tokenIdOrAmount,
    //     uint256 amountForERC1155
    // ) external onlyOwner {
    //     if (keccak256(abi.encodePacked(tokenType)) == keccak256(abi.encodePacked("ERC20"))) {
    //         IERC20 token = IERC20(tokenAddress);
    //         token.transferFrom(msg.sender, address(this), tokenIdOrAmount);
    //     } else if (keccak256(abi.encodePacked(tokenType)) == keccak256(abi.encodePacked("ERC721"))) {
    //         IERC721 token = IERC721(tokenAddress);
    //         token.safeTransferFrom(msg.sender, address(this), tokenIdOrAmount);
    //     } else if (keccak256(abi.encodePacked(tokenType)) == keccak256(abi.encodePacked("ERC1155"))) {
    //         IERC1155 token = IERC1155(tokenAddress);
    //         token.safeTransferFrom(msg.sender, address(this), tokenIdOrAmount, amountForERC1155, "");
    //     } else {
    //         revert("Invalid asset type");
    //     }
    //     if (s_tokenAddressTracker[tokenAddress] == false) {
    //         s_tokenAddresses.push(tokenAddress); // Add the token address to the array for sending logic
    //         s_tokenAddressTracker[tokenAddress] = true; // Mark the token address as added
    //     }
    // }
    //Native assets (ETH) will always be sent to the recipient address
    //TODO function to send assets to the recipient address (pops form the s_tokenAddresses array) and sets the s_tokenAddressTracker to false (callable by anyone but should be called by the backend service
    
}
