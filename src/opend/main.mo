import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import NFTACtorClass "../NFT/nft";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";

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
    private func addToOwnershipMap(owner: Principal, nftID: Principal){
        var ownedNFTs : List.List<Principal> = switch (mapOfOwners.get(owner)) {
            case (null) List.nil<Principal>();
            case (?result) result;
        };
        ownedNFTs := List.push<Principal>(nftID, ownedNFTs);
        mapOfOwners.put(owner, ownedNFTs);
    };
    public query func getOwnedNFTs(user: Principal) : async [Principal] {
        var userNFTs : List.List<Principal> = switch (mapOfOwners.get(user)) {
            case (null) List.nil<Principal>();
            case (?result) result;
        };
        return List.toArray(userNFTs);
    };
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
    public query func getOpendCanisterID() : async Principal {
        return Principal.fromActor(OpenD);
    };
};