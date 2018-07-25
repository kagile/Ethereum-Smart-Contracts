pragma solidity ^0.4.24;

/**
 * this contract provides a way to change the ownership of contract if needed.
 */
contract Migrations {
  address owner;
  uint lastCompletedMigration; 

  modifier restricted() {
    require (msg.sender == owner);
    _;
  }

  constructor() public {
    owner = msg.sender;
  }

  function setCompleted(uint _completed) public restricted {
    lastCompletedMigration = _completed;
  }

  function upgrade(address _newAddress) external restricted {
    Migrations upgraded = Migrations(_newAddress);
    upgraded.setCompleted(lastCompletedMigration);
  }
}