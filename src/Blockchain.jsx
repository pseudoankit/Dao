import Web3 from "web3";
import {setGlobalState, getGlobalState} from './store';
import abi from './abis/Dao.json';

const {etherum} = window;

window.web3 = new Web3(etherum);
window.web3 = new Web3(window.web3.currentProvider)

// file to connect web3 with react

const connectWallet = async () => {
    try {
        if(!etherum) return alert("Please install metamask extension in your browser")
        const accounts = await etherum.request({methods:"eth_requestAccounts"})
        setGlobalState('connectedAccount', accounts[0].toLowerCase())
    } catch(e) {
        reportError(e)
    }
}

const isWalletConnected = async () => {
    try {
        if(!etherum) return alert("Please install metamask extension in your browser")
        const accounts = await etherum.request({methods:"eth_accounts"})

        window.etherum.on("chainChanged", (chainId) => {
            window.location.reload()
        })

        window.etherum.on("accountsChanged", async () => {
            setGlobalState('connectedAccount', accounts[0].toLowerCase())
            await isWalletConnected()
        })

        if(accounts.length) {
            setGlobalState('connectedAccount', accounts[0].toLowerCase())
        } else {
            alert("Please connect wallet")
            console.log("no accounts found")
        }

    } catch(e) {
        reportError(e)
    }
}

const getEtherumContract = async () => {
    const connectedAccount = getGlobalState("connectAccount")
    if(connectedAccount) {
        const web3 = window.web3;
        const networkId = await web3.eth.net.getId()
        const networkData = await abi.networks[networkId]
        if(networkData) {
            return web3.eth.Contract(abi.abi, networkData.address)
        } else {
            return null
        }
    } else {
        return getGlobalState('contract')
    }
}

const performContribute = async () => {
    try {
        amount = window.web3.utils.toWei(amount.toString(), 'ether')
        const contract = await getEtherumContract()
        const account = getGlobalState('connectedAccount')
        await contract.methods.contribute().sender({from:account, value:amount})

        window.location.reload()
    } catch(e) {
        reportError(e)
        return e
    }
}

const getInfo = async () => {
    try {
        if(!etherum) return alert("Please install metamask extension in your browser")

        const contract = await getEtherumContract()
        const connectedAccount = getGlobalState('connectedAccount')
        const isStakeHolder = await contract.methods.isStakeHolder().call({from:connectedAccount})
        const balance = await contract.methods.daoBalance().call()
        const myBalance = await contract.methods.getBalance().call({from:connectedAccount})

        setGlobalState("balance", window.web3.utils.fromWei(balance))
        setGlobalState("myBalance", window.web3.utils.fromWei(myBalance))
        setGlobalState("isStakeHolder", isStakeHolder)
    } catch(e) {
        reportError(e)
    }
}

const raiseProposal = async ({title, description, beneficiary, amount}) => {
    try {
        amount = window.web3.utils.toWei(amount.toString(), 'ether')
        const contract = await getEtherumContract()
        const account = getGlobalState('connectedAccount')

        await contract.methods
            .createProposal(title,description, beneficiary, amount)
            .send({from: account})
    } catch(e) {
        reportError(e)
    }
}

const getProposals = async () => {
    try {
        if(!etherum) return alert("Please install metamask extension in your browser")
        const contract = await getEtherumContract()
        const proposals = await contract.methods.getProposals().call()
        setGlobalState('proposals', structuredProposals(proposals))
    } catch(e) {
        reportError(e)
    }
}

const structuredProposals = (proposals) => {
    return proposals.map((proposal) => ({
        id : proposal.id,
        amount : window.web3.utils.fromWei(proposal.amount),
        title : proposal.title,
        description : proposal.description,
        paid : proposal.paid,
        passed : proposal.passed,
        proposer : proposal.proposer,
        upvotes : Number(proposal.upvotes),
        downvotes : Number(proposal.downvotes),
        beneficiary : proposal.beneficiary,
        executor : proposal.executor,
        duration : proposal.duration
    }))
}

const getProposal = async(id) => {
    try {
        const proposals = getGlobalState('proposals')
        return proposals.find((proposal) => proposal.id === id)
    } catch(e) {
        reportError(e)
    }
}

const voteOnProposal = async (proposalId, supported) => {
    try {
        const contract = await getEtherumContract()
        const account = getGlobalState('connectedAccount')
        await contract.methods.vote(proposalId, supported).send({from: account})
        window.location.reload()
    } catch(e) {
        reportError(e)
    }
}

const listVoters = async(id) => {
    try {
        const contract = await getEtherumContract()
        const votes = await contract.methods.getVotesOf(id).call()
        return votes
    } catch(e) {
        reportError(e)
    }
}

const payoutBeneficiary = async(id) => {
    try {
        const contract = await getEtherumContract()
        const account = getGlobalState('connectedAccount')
        await contract.methods.payBeneficiary(id).send({from: account})
        window.location.reload()
    } catch(e) {
        reportError(e)
    }
}

const reportError = (e) => {
    console.log(Json.stringify(e), 'red')
    throw new Error('No etherum object, something is wrong')
}

export {
    isWalletConnected,
    connectWallet,
    performContribute,
    getInfo,
    raiseProposal,
    getProposals,
    getProposal,
    voteOnProposal,
    listVoters,
    payoutBeneficiary
}