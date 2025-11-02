module subscription::pass {
    use std::signer;
    use aptos_framework::timestamp;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_std::table::{Self, Table};
/// Error codes
    const ENOT_INITIALIZED: u64 = 1;
    const EINSUFFICIENT_BALANCE: u64 = 2;
const EALREADY_HAS_ACTIVE_PASS: u64 = 3;
    const EINVALID_DURATION: u64 = 4;
/// Pass duration options in seconds
    const DURATION_7_DAYS: u64 = 604800;
// 7 days
    const DURATION_30_DAYS: u64 = 2592000;
// 30 days
    const DURATION_90_DAYS: u64 = 7776000;
// 90 days
    const DURATION_365_DAYS: u64 = 31536000;
// 365 days

    /// Pass prices in octas (1 APT = 100,000,000 octas)
    const PRICE_7_DAYS: u64 = 5000000;
// 0.05 APT
    const PRICE_30_DAYS: u64 = 15000000;
// 0.15 APT
    const PRICE_90_DAYS: u64 = 40000000;
// 0.40 APT
    const PRICE_365_DAYS: u64 = 150000000;
// 1.50 APT

    /// User's pass information
    struct Pass has store, drop, copy {
        id: u64,
        purchased_at: u64,
        expires_at: u64,
        duration_days: u64,
        price_paid: u64,
    }

    /// Global pass store
    struct PassStore has key {
        next_pass_id: u64,
        
passes: Table<address, Pass>,
        total_passes_sold: u64,
        total_revenue: u64,
    }

    /// Initialize the pass store (call this once after deployment)
    public entry fun initialize(account: &signer) {
        let account_addr = signer::address_of(account);
if (!exists<PassStore>(account_addr)) {
            move_to(account, PassStore {
                next_pass_id: 1,
                passes: table::new(),
                total_passes_sold: 0,
                total_revenue: 0,
            });
}
    }

    /// Get price and duration for a given tier
    fun get_tier_details(duration_days: u64): (u64, u64) {
        if (duration_days == 7) {
            (PRICE_7_DAYS, DURATION_7_DAYS)
        } else if (duration_days == 30) {
            (PRICE_30_DAYS, DURATION_30_DAYS)
        } else if (duration_days == 90) {
         
   (PRICE_90_DAYS, DURATION_90_DAYS)
        } else if (duration_days == 365) {
            (PRICE_365_DAYS, DURATION_365_DAYS)
        } else {
            abort EINVALID_DURATION
        }
    }

    /// Purchase a subscription pass with APT payment
    public entry fun purchase_pass(
        buyer: &signer,
       
 store_owner: address,
        duration_days: u64
    ) acquires PassStore {
        assert!(exists<PassStore>(store_owner), ENOT_INITIALIZED);
let buyer_addr = signer::address_of(buyer);
        let store = borrow_global_mut<PassStore>(store_owner);
        
        // Get price and duration for selected tier
        let (price, duration_seconds) = get_tier_details(duration_days);
// Check if user has sufficient balance
        let balance = coin::balance<AptosCoin>(buyer_addr);
assert!(balance >= price, EINSUFFICIENT_BALANCE);

        // Transfer APT from buyer to store owner
        coin::transfer<AptosCoin>(buyer, store_owner, price);
let pass_id = store.next_pass_id;
        let now = timestamp::now_seconds();
        let expires = now + duration_seconds;
let new_pass = Pass {
            id: pass_id,
            purchased_at: now,
            expires_at: expires,
            duration_days,
            price_paid: price,
        };
        // Check if user already has an active pass
        if (table::contains(&store.passes, buyer_addr)) {
            let current_pass = table::borrow(&store.passes, buyer_addr);
            let now = timestamp::now_seconds();
            assert!(now >= current_pass.expires_at, EALREADY_HAS_ACTIVE_PASS);
            table::remove(&mut store.passes, buyer_addr);
        };
        table::add(&mut store.passes, buyer_addr, new_pass);        store.next_pass_id = pass_id + 1;
        store.total_passes_sold = store.total_passes_sold + 1;
        assert!(store.total_revenue <= (std::u64::MAX - price), EINSUFFICIENT_BALANCE); // Prevent overflow
        store.total_revenue = store.total_revenue + price;
}

    /// Internal function to check active pass
    fun has_active_pass_internal(store_owner: address, user: address): bool acquires PassStore {
        if (!exists<PassStore>(store_owner)) {
            return false
        };
let store = borrow_global<PassStore>(store_owner);
        if (!table::contains(&store.passes, user)) {
            return false
        };
let pass = table::borrow(&store.passes, user);
        let now = timestamp::now_seconds();
        now < pass.expires_at
    }

    #[view]
    /// Check if an address has an active (non-expired) pass
    public fun has_active_pass(store_owner: address, user: address): bool acquires PassStore {
        has_active_pass_internal(store_owner, user)
    }

    #[view]
    /// Get pass details for a user
    public fun get_pass_info(store_owner: address, user: address): (bool, u64, u64, u64, u64, u64) acquires PassStore {
        if (!exists<PassStore>(store_owner)) 
{
            return (false, 0, 0, 0, 0, 0)
        };
let store = borrow_global<PassStore>(store_owner);
        
        if (!table::contains(&store.passes, user)) {
            return (false, 0, 0, 0, 0, 0)
        };
let pass = table::borrow(&store.passes, user);
        let now = timestamp::now_seconds();
        let is_active = now < pass.expires_at;
(is_active, pass.id, pass.purchased_at, pass.expires_at, pass.duration_days, pass.price_paid)
    }

    #[view]
    /// Get total passes sold
    public fun get_total_passes_sold(store_owner: address): u64 acquires PassStore {
        if (!exists<PassStore>(store_owner)) {
            return 0
        };
let store = borrow_global<PassStore>(store_owner);
        store.total_passes_sold
    }

    #[view]
    /// Get total revenue collected
    public fun get_total_revenue(store_owner: address): u64 acquires PassStore {
        if (!exists<PassStore>(store_owner)) {
            return 0
        };
let store = borrow_global<PassStore>(store_owner);
        store.total_revenue
    }

    #[view]
    /// Get price for a specific tier (in octas)
    public fun get_tier_price(duration_days: u64): u64 {
        let (price, _) = get_tier_details(duration_days);
price
    }
}