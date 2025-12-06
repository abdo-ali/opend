import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import NFTACtorClass "../NFT/nft";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";

import List "mo:base/List";

actor OpenD {
    var mapOfNFTs = HashMap.HashMap<Principal, NFTACtorClass.NFT>(1, Principal.equal, Principal.hash);
    var mapOfOwners = HashMap.HashMap<Principal, List.List<Principal>>(1, Principal.equal, Principal.hash);

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
};