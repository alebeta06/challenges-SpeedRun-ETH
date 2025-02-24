// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

    mapping(address => uint256) public balances;

    uint256 public constant threshold = 1 ether;

    uint256 public deadline = block.timestamp + 72 hours;

    bool public openForWithdraw = true;
    bool public openForStake = true;

    event Stake(address, uint256);

   constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress); 
   }

  function stake() public payable {
    require(openForStake, "La recolecta se fue");
    require(block.timestamp < deadline, "La recolecta ya ha finalizado");
    balances[msg.sender] += msg.value;

    emit Stake(msg.sender, msg.value);

  }

  function execute() public {
    require(block.timestamp >= deadline, "La recolecta sigue abierta");
    
    if(address(this).balance >= threshold) {
    exampleExternalContract.complete{value: address(this).balance}();
    openForWithdraw = false;
    openForStake = false;
    }   
  }

  function timeLeft() public view returns(uint256) {
    if(block.timestamp < deadline) {
      return deadline - block.timestamp;
    }

    return 0;
  }

  function withdraw() public {
    require(balances[msg.sender] > 0, "No tienes fondos para retirar");
    require(address(this).balance < threshold, "No puedes retirar");
    require(openForWithdraw, "La recolecta ya se fue");
    uint256 value = balances[msg.sender];
    
    (bool response, /*bytes data*/) = msg.sender.call{value: value}("");
    require(response, "No se pudo realizar la transaccion");
    balances[msg.sender] = 0;
  }

  function receive() public {
    stake();
  }

}
