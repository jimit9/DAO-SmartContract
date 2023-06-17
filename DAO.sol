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
    mapping (address=>mapping (address=>bool)) public withdrawalStatus;
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
        contributionTimeEnd=_contributionEndTime;
        voteTime=_voteTime;
        quorum=_quorum;
        manager=msg.sender;
    }
}