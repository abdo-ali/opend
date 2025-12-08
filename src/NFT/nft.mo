import Debug "mo:base/Debug";
import Principal "mo:base/Principal";

actor class NFT (name: Text, owner: Principal, content: [Nat8]) = this {
    private let itemName = name;
    private var nftOwner = owner;
    private let imageBytes = content;

    public func getName() : async Text {
        return itemName;
    };
    
    public func getOwner() : async Principal {
        return nftOwner;
    };
    
    public func getContent() : async [Nat8] {
        return imageBytes;
    };

    public query func getCanisterID() : async Principal {
        return Principal.fromActor(this);
    };

    public shared(msg) func transferOwnership(newOwner: Principal) : async Text {
        if (msg.caller == nftOwner) {
            nftOwner := newOwner;
            return "success.";
        } else {
            return "Error: Not initiated by NFT owner.";
        };
    };
};