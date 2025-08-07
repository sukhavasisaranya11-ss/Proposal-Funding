module saranya_addr::ProposalFunding {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;

    /// Struct representing a funding proposal
    struct Proposal has store, key {
        title: vector<u8>,        // Proposal title
        funding_amount: u64,      // Requested funding amount
        total_votes: u64,         // Total votes received
        is_approved: bool,        // Approval status
        is_funded: bool,          // Funding status
        proposer: address,        // Address of the proposer
    }

    /// Struct to track voting records
    struct VoteRecord has store, key {
        voted_proposals: vector<address>, // List of proposals voted on
    }

    /// Function to create a new funding proposal
    public fun create_proposal(
        proposer: &signer, 
        title: vector<u8>, 
        funding_amount: u64
    ) {
        let proposal = Proposal {
            title,
            funding_amount,
            total_votes: 0,
            is_approved: false,
            is_funded: false,
            proposer: signer::address_of(proposer),
        };
        move_to(proposer, proposal);
        
        // Initialize vote record if not exists
        if (!exists<VoteRecord>(signer::address_of(proposer))) {
            let vote_record = VoteRecord {
                voted_proposals: vector::empty(),
            };
            move_to(proposer, vote_record);
        };
    }

    /// Function to automatically fund approved proposals
    public fun fund_approved_proposal(
        funder: &signer, 
        proposal_address: address
    ) acquires Proposal {
        let proposal = borrow_global_mut<Proposal>(proposal_address);
        
        // Check if proposal is approved and not yet funded
        assert!(proposal.is_approved, 1); // Error: Proposal not approved
        assert!(!proposal.is_funded, 2);  // Error: Proposal already funded
        
        // Transfer funds from funder to proposer
        let funding = coin::withdraw<AptosCoin>(funder, proposal.funding_amount);
        coin::deposit<AptosCoin>(proposal.proposer, funding);
        
        // Mark proposal as funded
        proposal.is_funded = true;
    }
}