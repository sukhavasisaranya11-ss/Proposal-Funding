module saranya_addr::ProposalFunding {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use std::vector;

   
    struct Proposal has store, key {
        title: vector<u8>,       
        funding_amount: u64,     
        total_votes: u64,        
        is_approved: bool,        
        is_funded: bool,          
        proposer: address,        
    }

   
    struct VoteRecord has store, key {
        voted_proposals: vector<address>, 
    }

    
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
        
        ]
        if (!exists<VoteRecord>(signer::address_of(proposer))) {
            let vote_record = VoteRecord {
                voted_proposals: vector::empty(),
            };
            move_to(proposer, vote_record);
        };
    }

  ]
    public fun fund_approved_proposal(
        funder: &signer, 
        proposal_address: address
    ) acquires Proposal {
        let proposal = borrow_global_mut<Proposal>(proposal_address);
        ]
        assert!(proposal.is_approved, 1); 
        assert!(!proposal.is_funded, 2);  
        
        let funding = coin::withdraw<AptosCoin>(funder, proposal.funding_amount);
        coin::deposit<AptosCoin>(proposal.proposer, funding);
        
        proposal.is_funded = true;
    }

}

