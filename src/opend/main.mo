import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import NFTACtorClass "../NFT/nft";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";

import List "mo:base/List";

actor OpenD {
    private type Listing = {
        itemOwner: Principal;
        itemPrice: Nat;
        // you can add more fields if needed
        // e.g., timestamp, description, history, etc.
        // for simplicity, we keep it minimal
    };

    var mapOfNFTs = HashMap.HashMap<Principal, NFTACtorClass.NFT>(1, Principal.equal, Principal.hash);
    var mapOfOwners = HashMap.HashMap<Principal, List.List<Principal>>(1, Principal.equal, Principal.hash);
    var mapOfListing = HashMap.HashMap<Principal, Listing>(1, Principal.equal, Principal.hash);
    // to mint a new NFT and register it in OpenD canister maps
    public shared(msg) func mint (imgdata: [Nat8], name: Text) : async Principal {
        let owner: Principal = msg.caller;

        Debug.print(debug_show(Cycles.balance()));
        Cycles.add(100_500_000_000);
        let newNFT = await NFTACtorClass.NFT(name, owner, imgdata);
        Debug.print(debug_show(Cycles.balance()));

        let newNftPrincipal = await newNFT.getCanisterID();
        mapOfNFTs.put(newNftPrincipal, newNFT);
        addToOwnershipMap(owner, newNftPrincipal);
        return newNftPrincipal;
    };
    // to update the ownership map when a new NFT is minted 
    private func addToOwnershipMap(owner: Principal, nftID: Principal){
        var ownedNFTs : List.List<Principal> = switch (mapOfOwners.get(owner)) {
            case (null) List.nil<Principal>();
            case (?result) result;
        };
        ownedNFTs := List.push<Principal>(nftID, ownedNFTs);
        mapOfOwners.put(owner, ownedNFTs);
    };
    // to get all NFTs owned by a user
    public query func getOwnedNFTs(user: Principal) : async [Principal] {
        var userNFTs : List.List<Principal> = switch (mapOfOwners.get(user)) {
            case (null) List.nil<Principal>();
            case (?result) result;
        };
        return List.toArray(userNFTs);
    };
    // to get all listed NFTs
    public query func getListedNFTs() : async [Principal] {
        let ids = Iter.toArray(mapOfListing.keys());
        return ids;
    };
    // to list an NFT for sale
    public shared(msg) func listItem(id: Principal, price: Nat) : async Text {
        var item : NFTACtorClass.NFT = switch (mapOfNFTs.get(id)) {
            case (null) {
                Debug.print("NFT not found");
                return "NFT not found";
            };
            case (?result) result;
        };
        let owner = await item.getOwner();
        if (Principal.equal(owner, msg.caller)) {
            let newListing : Listing = {
                itemOwner = owner;
                itemPrice = price;
                // you can add more fields if needed
                // e.g., timestamp, description, history, etc.
                // for simplicity, we keep it minimal
            };
            mapOfListing.put(id, newListing);
            return "success";
        } else {
            return "You don't own this NFT";
        };
    };
    // to get OpenD canister ID
    public query func getOpendCanisterID() : async Principal {
        return Principal.fromActor(OpenD);
    };
    // to check if an NFT is listed to sell
    public query func isListed(id: Principal) : async Bool {
        let listing = mapOfListing.get(id);
        switch (listing) {
            case (null) return false;
            case (?_) return true;
        };
    };
    // to get the original owner of a listed to sell NFT
    public query func getOriginalOwner(id: Principal) : async Principal {
        var listing : Listing = switch (mapOfListing.get(id)) {
            case (null) return Principal.fromText("");
            case (?result) result;
        };
        return listing.itemOwner;
    };
    // to get the price of a listed to sell NFT
    public query func getListingNFTPrice (id: Principal) : async Nat {
        var listing : Listing = switch (mapOfListing.get(id)) {
            case (null) return 0;
            case (?result) result;
        };
        return listing.itemPrice;
    };

    public shared(msg) func completePurchase(id: Principal, ownerId: Principal,newOwnerId: Principal) : async Text {
        var purchasedNFT : NFTACtorClass.NFT = switch (mapOfNFTs.get(id)) {
            case (null) return "NFT does not exist.";
            case (?result) result;
        };
        let transferResult = await purchasedNFT.transferOwnership(newOwnerId);
        if (transferResult == "success.") {
            // remove from listing map
            mapOfListing.delete(id);
            var ownedNFTs : List.List<Principal> = switch (mapOfOwners.get(ownerId)) {
                case (null) List.nil<Principal>();
                case (?result) result;
            };
            ownedNFTs := List.filter(ownedNFTs, func (listedItem: Principal) : Bool {
                return listedItem != id;
            });
            // mapOfOwners.put(ownerId, ownedNFTs);
            addToOwnershipMap(newOwnerId, id);
            return "Success";
        } else {
            return transferResult;
        };
            
    };

};