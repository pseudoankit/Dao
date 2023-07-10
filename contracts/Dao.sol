// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/secuiry/ReentrancyGuard.sol";

contract Dao is ReentrancyGuard, AccessControl{
    bytes32 private immutable CONTRIBUTOR_ROLE = keccak256("CONTRIBUTOR");
    bytes32 private immutable STAKEHOLDER_ROLE = keccak256("STAKEHOLDER");

    uint32 totalPropsals;
    uint256 public daoBalance;

    mapping(uint256 => ProposalStruct) private raisedProposals;
    mapping(address => uint256[]) private stakholderVotes;
    mapping(address => VotedStruct[]) private votedOn;
    mapping(address => uint256) private contributors;
    mapping(address => uint256) private stakeholders;

    struct ProposalStruct {
        uint256 id;
        uint256 amount;
        uint256 duration;
        uint256 upvotes;
        uint256 downvotes;
        string title;
        string description;
        bool passed;
        bool paid;
        address payable beneficiary;
        address proposer;
        address executor;
    }

    struct VotedStruct {
        address voter;
        uint256 timestamp;
        bool choosen;
    }

    event Action(
        address indexed initator,
        bytes32 role,
        string message,
        address indexed beneficiary,
        uint256 amount
    );

    modifier stakholderOnly(sting memory message) {
        required(hasRole(STAKEHOLDER_ROLE, msg.sender), message);)
        _;
    }

    modifier contributroOnly(sting memory message) {
        required(hasRole(CONTRIBUTOR_ROLE, msg.sender), message);)
        _;
    }

    function createProposal(
        string memory title,
        string memory description,
        address beneficiary,
        uint amount
    ) external stakholderOnly("propal creation allowed for stakholders only") {
        uint 256 propsalId = totalProposers++;
        PropalsStruct storage proposal = raisedProposals[proposalId]

        proposal.id = proposalId;
        proposal.propers = payable(msg.sender);
        proposal.desciption=desciption;
        proposal.title = title;
        proposal.beneficiary = payable(beneficiary);
        proposal.amount = amount;
        proposal.duration = block.timestamp+MIN)VOTE_DURATION;  

        emit Action(
            msg.sender,
            STAKEHOLDER_ROLE,
            "PROPOSAL RAISED",
            befeciary,
            amount
        )
    }

    function handleVoting(ProposalStruct storage propsal) private {
        if(proposal.passed || proposal.duration <= block.timestamp) {
            proposal.passed=true;
            revert("proposal duration expired);
        }

        uint 256[] memory tempVotes = stakholderVotes[msg.sender];
        for(uint256 votes=0;votes<tempVotes;votes++) {
            if(proposal.id == tempVotes[vote]) {
                revert("double voting not allowed);
            }
        }
    }

    function vote(uint256 propsalId, bool choosen) external stakeholderOnly("Stake holder only allowed") returns (VotedStruct memory){
        Proposalstruct storage proposal = raisedProposals[proposalId];
        handleVoting(proposal);
        if(choosen) personal.upvotes++;
        else proposal.downvotes++;

        stakholderVotes[msg.sender].push(propsal.id)
        votesOn[proposalid].push(
            VotedStruct(
                msg.sender,
                block.timestamp,
                choosen
            )
        )

        emit Action(
            msg.sender,
            STAKEHOLDER_ROLE,
            "proposal vote",
            proposal.beneficiary,
            proposal.amount
        )

        return VotedStruct(
            msg.sender,
            block.timestamp,
            choosen
        )
    }       
}