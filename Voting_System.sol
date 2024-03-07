// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {

    mapping (address => bool) privilege;

    uint constant VOTE_THRESHOLD = 10;

    constructor(address[] memory allowed) public{
        for(uint i= 0;i<allowed.length;i++){
            privilege[allowed[i]] = true;
        }
        privilege[msg.sender] = true;
    }

    enum Status{
        None,
        Yes,
        No
    }
    
    struct Proposal {
        address target;
        bytes data;
        bool executed;
        uint yesCount;
        uint noCount;
        mapping(address => Status) status;
    }

    Proposal[] public proposals;

    event ProposalCreated(uint);
    event VoteCast(uint, address indexed);

    function newProposal(address addr, bytes calldata data) external{
        require(privilege[msg.sender]);
        Proposal storage proposal = proposals.push();
        proposal.target = addr;
        proposal.data = data;
        emit ProposalCreated(proposals.length-1);
    }

    function castVote(uint id, bool response) external {
        require(privilege[msg.sender]);
        Proposal storage proposal = proposals[id];
        if(proposal.status[msg.sender] == Status.Yes){
            proposal.yesCount--;
        }

        if(proposal.status[msg.sender] == Status.No){
            proposal.noCount--;
        }

        if(response == true){
            proposals[id].yesCount += 1;
        }else{
            proposals[id].noCount += 1;
        }
        proposal.status[msg.sender] = response ? Status.Yes : Status.No;
        emit VoteCast(id, msg.sender);

        if(proposal.yesCount == VOTE_THRESHOLD && !proposal.executed){
            (bool success, ) = proposal.target.call(proposal.data);
            require(success);
        }
    }    
}
