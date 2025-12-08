export const idlFactory = ({ IDL }) => {
  const NFT = IDL.Service({
    'getCanisterID' : IDL.Func([], [IDL.Principal], ['query']),
    'getContent' : IDL.Func([], [IDL.Vec(IDL.Nat8)], []),
    'getName' : IDL.Func([], [IDL.Text], []),
    'getOwner' : IDL.Func([], [IDL.Principal], []),
    'transferOwnership' : IDL.Func([IDL.Principal], [IDL.Text], []),
  });
  return NFT;
};
export const init = ({ IDL }) => {
  return [IDL.Text, IDL.Principal, IDL.Vec(IDL.Nat8)];
};
