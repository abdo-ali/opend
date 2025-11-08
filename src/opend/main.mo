import Cycles "mo:base/ExperimentalCycles";
import Principal "mo:base/Principal";
import NFTACtorClass "../NFT/nft";
import Debug "mo:base/Debug";
actor OpenD {
    public shared(msg) func mint (imgdata: [Nat8], name: Text) : async Principal {
        let owner: Principal = msg.caller;

        Debug.print(debug_show(Cycles.balance()));
        Cycles.add(100_500_000_000);
        let newNFT = await NFTACtorClass.NFT(name, owner, imgdata);
        let newNftPrincipal = await newNFT.getCanisterID();
        Debug.print(debug_show(Cycles.balance()));

        return newNftPrincipal;
    };
};
