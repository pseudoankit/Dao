// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/secuiry/ReentrancyGuard.sol";

contract Dao is ReentrancyGuard, AccessControl{
    bytes32 private immutable CONTRIBUTOR_ROLE = keccak256("CONTRIBUTOR");
    bytes32 private immutable STAKEHOLDER_ROLE = keccak256("STAKEHOLDER");
    uint256 private MIN_STAKEHOLDER_CONTRIBUTION = 1 ether;
    uint256 private MIN_VOTE_DURATION = 3 minutes;

    uint32 totalPropsals;
    uint256 public daoBalance;

    // all the proposals raised (proposal id to data)
    mapping(uint256 => ProposalStruct) private raisedProposals;
    // mapping of votes given by individual stakeholder (individual address to list<proposals voted>)
    mapping(address => uint256[]) private stakholderVotes;
    // voting information about a proposal, (proposal id to voting data)
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
        required(hasRole(STAKEHOLDER_ROLE, msg.sender), message);
        _;
    }

    modifier contributroOnly(sting memory message) {
        required(hasRole(CONTRIBUTOR_ROLE, msg.sender), message);
        _;
    }

    function createProposal(
        string memory title,
        string memory description,
        address beneficiary,
        uint amount
    ) external stakholderOnly("propal creation allowed for stakholders only") {
        uint256 propsalId = totalProposers++;
        PropalsStruct storage proposal = raisedProposals[proposalId];

        proposal.id = proposalId;
        proposal.propers = payable(msg.sender);
        proposal.desciption=desciption;
        proposal.title = title;
        proposal.beneficiary = payable(beneficiary);
        proposal.amount = amount;
        proposal.duration = block.timestamp+MIN_VOTE_DURATION;  

        emit Action(
            msg.sender,
            STAKEHOLDER_ROLE,
            "PROPOSAL RAISED",
            beneficiary,
            amount
        );
    }

    function handleVoting(ProposalStruct storage propsal) private {
        if(proposal.passed || proposal.duration <= block.timestamp) {
            proposal.passed=true;
            revert("proposal duration expired");
        }

        uint256[] memory tempVotes = stakholderVotes[msg.sender];
        for(uint256 votes=0;votes<tempVotes;votes++) {
            if(proposal.id == tempVotes[vote]) {
                revert("double voting not allowed");
            }
        }
    }

    function vote(uint256 propsalId, bool choosen) external stakeholderOnly("Stake holder only permitted") returns (VotedStruct memory){
        Proposalstruct storage proposal = raisedProposals[propsalId];
        handleVoting(proposal);
        if(choosen) proposal.upvotes++; else proposal.downvotes++;

        stakholderVotes[msg.sender].push(propsal.id);
        votesOn[propsalId].push(
            VotedStruct(
                msg.sender,
                block.timestamp,
                choosen
            )
        );

        emit Action(
            msg.sender,
            STAKEHOLDER_ROLE,
            "proposal vote",
            proposal.beneficiary,
            proposal.amount
        );

        return VotedStruct(
            msg.sender,
            block.timestamp,
            choosen
        );
    }     

    function payTo(address to, uint amount) internal returns(bool) {
        (bool success,) = payable(to).call{value: amount}("");
        require(success, "Payment failed something went wrong");
        return true;
    }  

    function payBeneficiary(uint proposalId) public
     stakeholderOnly("Unauthorized stakeholder only") nonReentrant() 
     returns(uint256) {
        ProposalStruct storage proposal = raisedProposals[proposalId];
        require(daoBalance >= proposal.amount, "Insufficient funds");

        if(proposal.paid) revert("Payment is already sent");
        if(proposal.upvotes <= proposal.downvotes) revert("Insufficent votes");

        proposal.paid = true;
        proposal.executor = msg.sender;
        daoBalance-=proposal.amount;

        payTo(proposal.beneficiary, proposal.amount);

        emit Action(msg.sender, STAKEHOLDER_ROLE, "payment transferred", proposal.beneficiary, proposal.amount);

        return daoBalance;
    }

    function contribute() public payable {
        require(msg.value > 0, "Contribution should be more that zero");
        if(!hasRole(STAKEHOLDER_ROLE, msg.sender)) {
            uint256 totalContribution = contributors[msg.sender] + msg.value;
            if(totalContribution >= MIN_STAKEHOLDER_CONTRIBUTION) {
                stakeholders[msg.sender] = totalContribution;
                _grantRole(STAKEHOLDER_ROLE, msg.sender);
            }
            contributors[msg.sender]+=msg.value;
            _grantRole(CONTRIBUTOR_ROLE, msg.sender);
        } else {
            contributors[msg.sender] += msg.value;
            stakeholders[msg.sender] += msg.value;
        }

        daoBalance+=msg.value;

        emit Action(msg.sender, CONTRIBUTOR_ROLE, "Contribution received", address(this), msg.value);
    }
}