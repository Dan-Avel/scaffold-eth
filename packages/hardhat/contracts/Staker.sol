
pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public balance = 0 ether;
  uint256 public deadline;
  bool isComplete = false;
  bool penForWithdraw = false;

  event Stake(address sender, uint amount);
  
  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    deadline = now + 120 seconds;
  }

  modifier aboveThreshold() {
    require( address(this).balance >= threshold, "Insufficient funds in Contract");
    _;
  }

  modifier belowThreshold() {
    require( address(this).balance < threshold, "Insufficient funds in Contract");
    _;
  }

  modifier afterDeadline() {
    require( now > deadline, "Deadline has not passed.");
    _;
  }

  modifier beforeDeadline() {
    require( now <= deadline, "Deadline has passed.");
    _;
  }

  modifier notCompleted() {
    require( isComplete == false, "Not Complete.");
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable beforeDeadline returns (uint256) {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
    if (address(this).balance >= threshold) {
      
    }
    return address(this).balance;
  }


  // After some `deadline` allow anyone to call an `execute()` function
  function execute() public afterDeadline aboveThreshold notCompleted {
    //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

    exampleExternalContract.complete{value: address(this).balance}();
    isComplete = true;
    // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  }


  function withdraw() public payable afterDeadline belowThreshold notCompleted {
    // get the amount of Ether stored in this contract
    uint amount = address(this).balance;

    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Failed to send Ether");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if (now <= deadline) {
      return deadline - now;
    } else {
      return uint256(0);
    }
  }

// ryan @moonshot coordinator

}