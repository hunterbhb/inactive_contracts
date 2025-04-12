// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

//TODO Have a function that takes the users address and creates a contract for them.
//TODO they will be the "owner" of the contract and can set the address to send the assets to. This can also bedone on creation
//TODO get the amount of link needed for the contract creation and gas fees.
//TODO they can also set the number of assets to send.
//TODO use chainlink keepers to automate the sending of assets after a certain time has passed.
//TODO helper function to determine needed gas fees for the contract creation and sending of assets. (in link)
//TODO they can also set the time to send the assets. or how long they can be inactive before the assets are sent. to the address/es
//TODO on contract creation give an option to either allow pulling of assets or no pulling of assets.
//TODO for every new asset added to the contract (except ETH), the contract will need more funding of ETH to cover the gas fees. and there's a genral fee for the contract creation for dev.
interface IUserCreatedContract {
    function calculateChainlinkFee() external view returns (uint256); //Fees of both chainlink automation and regular gas fees
    function getRecipient() external view returns (address);
    function getTimeToSend() external view returns (uint256 timeLeftSecs, uint256 timestamp);
    function getIsPullingAllowed() external view returns (bool); //On contract creation, this will determine if the contract allows pulling of assets or not (Only one way)
    function getOwner() external view returns (address);
    function setRecipient(address newRecipient) external;
    function setTimeToSend(uint256 newTimeToSend) external;
}
