// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 < 0.9.0;
contract dao{
    struct Proposal{
uint id;
string description;
uint amount;
address payable receipient;
uint votes;
uint end;
bool isExecuted;
    }
    mapping (address=>bool) public isInvestor;
    mapping (address=>uint) public numOfShares;
    mapping (address => mapping (uint=>bool)) public isVoted;
    address[] public investorsList;
    mapping (uint=>Proposal) public proposals;
    
    uint public totalShares;
    uint public availableFunds;
    uint public contributionTimeEnd;
    uint public nextProposalId;
    uint public voteTime;
    uint public quorum;
    address public manager;
    constructor(uint _contributionEndTime,uint _voteTime,uint _quorum){
        require(_quorum>0 && _quorum<100,"not valid value");
        contributionTimeEnd=block.timestamp + _contributionEndTime;
        voteTime=_voteTime;
        quorum=_quorum;
        manager=msg.sender;
    }
    modifier onlyManager(){
        require(manager==msg.sender,"you're not a manager");
        _;
    }
    modifier onlyInvestor(){
        require(isInvestor[msg.sender]==true,"You're not an investor");
        _;
    }
    function contribution() public payable{
        require(contributionTimeEnd>block.timestamp,"contribution time ended");
        require(msg.value>0,"send more than 0 ether");
        isInvestor[msg.sender]=true;
        numOfShares[msg.sender]+=msg.value;
        totalShares+=msg.value;
        availableFunds+=msg.value;
        investorsList.push(msg.sender);
    }
    function redeemShare(uint amount) public onlyInvestor(){
        require(numOfShares[msg.sender]>=amount,"You do not have enough shares");
        require(availableFunds>=amount,"You don't have enogh funds");
        numOfShares[msg.sender]-=amount;
        if(numOfShares[msg.sender]==0) {
                isInvestor[msg.sender]=false;
        }
        availableFunds-=amount;
        payable(msg.sender).transfer(amount);
    }
function transferShare(uint amount,address to) public onlyInvestor(){
require(numOfShares[msg.sender]>=amount,"You do not have enough shares");
        require(availableFunds>=amount,"You don't have enogh funds");
         numOfShares[msg.sender]-=amount;
             if(numOfShares[msg.sender]==0) {
                isInvestor[msg.sender]=false;
        }
        
        numOfShares[to]+=amount;
        isInvestor[to]=true;
        investorsList.push(to);

}
function createProposal(string calldata description,uint amount,address payable receipient) public onlyManager{
require(availableFunds>=amount,"Not enough funds");
proposals[nextProposalId]=Proposal(nextProposalId,description,amount,receipient,0,block.timestamp+voteTime,false);
nextProposalId++;
}
function voteProposal(uint proposalId) public onlyInvestor {
    Proposal storage _proposal = proposals[proposalId];
    require(isVoted[msg.sender][proposalId]==false,"You've already voted");
    require(_proposal.isExecuted==false,"This proposal is already executed");
    isVoted[msg.sender][proposalId]=true;
    _proposal.votes+=numOfShares[msg.sender];
}
function executeProposal(uint proposalId) public onlyManager{
    Proposal storage _proposal = proposals[proposalId];
    require(_proposal.isExecuted==false,"This proposal is already executed");
    require((_proposal.votes/totalShares)*100>=quorum,"Majority does not support this proposal");
    _proposal.isExecuted=true;
    _proposal.receipient.transfer(_proposal.amount);
    availableFunds-=_proposal.amount;
}
function proposalList() public view returns (Proposal[] memory){
Proposal[] memory arr = new Proposal[](nextProposalId-1);
for (uint i=1; i<nextProposalId;i++) 
{
    arr[i]=proposals[i];
}
return arr; 
}
}