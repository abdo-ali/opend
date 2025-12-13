import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
// NFT canister class definition
actor class NFT (name: Text, owner: Principal, content: [Nat8]) = this {
    private let itemName = name;
    private var nftOwner = owner;
    private let imageBytes = content;
    // to get NFT details like name, owner, content
    public func getName() : async Text {
        return itemName;
    };
    // to get the current owner of the NFT
    public func getOwner() : async Principal {
        return nftOwner;
    };
    // to get the image content of the NFT as byte array
    public func getContent() : async [Nat8] {
        return imageBytes;
    };
    // to get the canister ID of the NFT
    public query func getCanisterID() : async Principal {
        return Principal.fromActor(this);
    };
    // to transfer ownership of the NFT to a new owner
    public shared(msg) func transferOwnership(newOwner: Principal) : async Text {
        if (msg.caller == nftOwner) {
            nftOwner := newOwner;
            return "success.";
        } else {
            return "Error: Not initiated by NFT owner.";
        };
    };
};