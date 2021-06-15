//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;
// ----------------------------------------
// KYC
// ----------------------------------------
interface KYCInterface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    //function knowYourKYCStatus(address tokenOwner) external view returns (uint balance);
    function transfer(address to) external returns (bool success);
    function approveKYC(address to) external returns (bool success);
    function submitKYC() external returns (bool success);
    function rejectKYC(address to) external returns (bool success);
    function processKYC(address to) external returns (bool success);
    
    //function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    //function approve(address spender, uint tokens) external returns (bool success);
    //function transferFrom(address from, address to, uint tokens) external returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    //event Approval(address indexed tokenOwner, address indexed spender);
}



contract KYC is KYCInterface{
    
    string public name = "KnowYourCustomer";
    string public symbol = "KYC";
    uint public decimals = 0; //18 is very common
    uint public override totalSupply;
    
    address public founder;
    mapping(address => uint) public KYCTokens;
    enum Statuses {NotStarted,Submitted, InProgress, Completed, Rejected}
    Statuses KYCStatuses;
    
    mapping(address => Statuses) public KYCStatus;
    
    modifier onlyFounder {
        require(founder==msg.sender, "only founder can call this function");
    _;
    }
    
    modifier Completed (address to) {
        require(KYCStatus[to] == Statuses.Completed, "This KYC is not Completed");
    _;
    }
    
    modifier notCompleted (address to) {
        require(KYCStatus[to] != Statuses.Completed, "This is already completed the KYC");
    _;
    }
    
    modifier Rejected (address to) {
        require(KYCStatus[to] == Statuses.Rejected, "This KYC is not rejected");
    _;
    }
    
    modifier notRejected (address to) {
        require(KYCStatus[to] != Statuses.Rejected, "You have already rejected this KYC");
    _;
    }
    
    modifier notInProgress (address to) {
        require(KYCStatus[to] != Statuses.InProgress, "You have already submitted the KYC");
    _;
    }
    
    modifier notSubmitted (address to) {
        require(KYCStatus[to] != Statuses.NotStarted, "Yet to submit the KYC");
    _;
    }

    constructor(){
        totalSupply = 1000000;
        founder = msg.sender;
        KYCTokens[founder] = totalSupply;
    }
    
    function balanceOf(address tokenOwner) public view override returns (uint balance){
        return KYCTokens[tokenOwner];
    }
    
    function knowYourKYCStatus(address tokenOwner) public view returns (Statuses){
         return KYCStatus[tokenOwner];
    }
    
    function transfer(address to) public override onlyFounder Completed(to) returns(bool success){
        require(KYCTokens[msg.sender] >= 0,"Founder should have more than zero tokens to complete the KYC");
        require(KYCTokens[to] == 0, "Recipient already completed the KYC");
        
        KYCTokens[msg.sender] -= 1;
        KYCTokens[to] = 1;
        emit Transfer(msg.sender, to,1);
        
        return true;
    }
    
    function approveKYC(address to) public override onlyFounder notSubmitted(to) notCompleted(to) notRejected(to) returns (bool success){
        KYCStatus[to] = Statuses.Completed;
        //emit Approval(msg.sender, to);
        return true;
    }
    
    function submitKYC() public override notCompleted(msg.sender) notInProgress(msg.sender) returns (bool success){
        KYCStatus[msg.sender] = Statuses.Submitted;
       // emit Approval(founder, msg.sender);
        return true;
    }
    
    function rejectKYC(address to) public override onlyFounder notSubmitted(to) notCompleted(to) returns (bool success){
        KYCStatus[to] = Statuses.Rejected;
       // emit Approval(msg.sender, to);
        return true;
    }
    
    function processKYC(address to) public override onlyFounder notSubmitted(to) notCompleted(to) notRejected(to) returns (bool success){
        KYCStatus[to] = Statuses.InProgress;
       // emit Approval(msg.sender, to);
        return true;
    }
}