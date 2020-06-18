//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.7.0;

/**
  @dev this will container all the funds
  @author Bhasin Neeraj
 */

import "./SafeMath.sol";

contract LoanWallet {
    using SafeMath for uint256;
    //EVENTS
    event Deposited(address indexed, uint256 indexed);
    event Withdrawal(address indexed, uint256 indexed);
    //MODULES
    mapping(address => uint256) private _balance;

    constructor() public {}

    function deposit(address _to) public payable {
        uint256 amount = msg.value;
        _balance[_to] = _balance[_to].add(amount);
        emit Deposited(_to, amount);
    }

    function withdraw(address payable _to, uint256 _amount) public {
        _balance[_to] = _balance[_to].sub(_amount);
        _to.transfer(_amount);
        emit Withdrawal(_to, _amount);
    }
}
