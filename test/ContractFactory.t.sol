// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import "../src/ContractFactory.sol";
import "forge-std/console.sol";

contract ContractFactoryTest is Test {
    ContractFactory public factory;
    address public owner = address(2);
    address public user = address(3);
    address public recipient = address(5);
    address public USDCAddress = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address public WETH = 0x4200000000000000000000000000000000000006;
    uint256 public devFee = 1 ether;

    function setUp() public {
        vm.startPrank(owner);
        factory = new ContractFactory(devFee);
        vm.stopPrank();
    }

    function testCreateContract() public {
        address[] memory tokenAddresses = new address[](2);
        tokenAddresses[0] = USDCAddress;
        tokenAddresses[1] = WETH;

        uint256 timeToSend = block.timestamp + 1 days;
        uint256 secondsToAdd = 3600;

        uint256 currentBalance = owner.balance;
        address newContract = createContractHelper(recipient, timeToSend, tokenAddresses, secondsToAdd);

        assertTrue(newContract != address(0), "New contract should be deployed");
        assertTrue(owner.balance == currentBalance + devFee, "Developer fee should be transferred to the factory owner");
    }

    function createContractHelper(
        address _recipient,
        uint256 _timeToSend,
        address[] memory _tokenAddresses,
        uint256 _secondsToAdd
    ) internal returns (address) {
        vm.startPrank(user);
        vm.deal(user, devFee); // Ensure the user has enough ETH to pay the fee

        // Call the createContract function
        (bool success, bytes memory data) = address(factory).call{value: devFee}(
            abi.encodeWithSignature(
                "createContract(address,uint256,address[],uint256)",
                _recipient,
                _timeToSend,
                _tokenAddresses,
                _secondsToAdd
            )
        );
        require(success, "Contract creation failed");

        // Decode the returned address
        address newContract = abi.decode(data, (address));
        vm.stopPrank();

        return newContract;
    }
}
