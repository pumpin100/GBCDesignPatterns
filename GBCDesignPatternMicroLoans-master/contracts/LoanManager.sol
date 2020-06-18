//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.7.0;

/**
  @dev manage all the operations
  @author Bhasin Neeraj
 */
import "./LoanDB.sol";
import "./LoanWallet.sol";

contract LoanManager is LoanDB, LoanWallet {
    constructor() public {}

    function requestForLoan(
        uint256 _debtNo,
        address _borrower,
        uint256 _amount
    ) external {
        require(_amount >= 1e16 wei, "The amount is too small to borrow");
        require(
            LoanDB(address(this)).getBorrowerofDebt(_debtNo) == address(0),
            "debt exists"
        );
        require(
            LoanDB(address(this)).checkHaveDebt(_borrower) == false,
            "already have Debt"
        );
        uint256 _interest = (_amount.mul(5)).div(100);
        LoanDB(address(this)).addDebt(_debtNo, _borrower, _amount, _interest);
    }

    function lendLoan(uint256 _debtNo, address _sender) external payable {
        uint256 _amount = LoanDB(address(this)).getAmountofDebt(_debtNo);
        address _borrower = LoanDB(address(this)).getBorrowerofDebt(_debtNo);
        require(
            LoanDB(address(this)).getStateofDebt(_debtNo) ==
                uint256(LoanState.PENDING),
            "Not in requested state"
        );
        require(msg.value >= _amount, "Not enough amount");
        require(_borrower != address(0), "Debt is not existing");
        require(
            LoanDB(address(this)).checkHaveDebt(_borrower) == false,
            "already have Debt"
        );
        LoanWallet(address(this)).deposit.value(msg.value)(_borrower);
        LoanDB(address(this)).updateLender(_debtNo, _sender);
        LoanDB(address(this)).setHaveDebt(_borrower, true);
    }

    function payLoan(uint256 _debtNo, address _sender) external payable {
        uint256 _amount = LoanDB(address(this)).getAmountofDebt(_debtNo).add(
            LoanDB(address(this)).getInterestofDebt(_debtNo)
        );
        require(msg.value >= _amount, "Not enough amount");
        require(_amount != 0, "Debt is not existing");
        require(
            LoanDB(address(this)).getStateofDebt(_debtNo) ==
                uint256(LoanState.ACTIVE),
            "Not in funded state"
        );
        address _lender = LoanDB(address(this)).getLenderofDebt(_debtNo);
        require(_lender != address(0), "Does not have lender");
        LoanWallet(address(this)).deposit.value(msg.value)(_lender);
        LoanDB(address(this)).paidDebt(_debtNo);
        LoanDB(address(this)).setHaveDebt(_sender, false);
    }
}
