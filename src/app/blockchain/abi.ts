export const abi = [
    {
      inputs: [
        {
          internalType: "uint256",
          name: "_expirationTimeInSeconds",
          type: "uint256",
        },
      ],
      stateMutability: "nonpayable",
      type: "constructor",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "address",
          name: "from",
          type: "address",
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "amount",
          type: "uint256",
        },
        {
          indexed: true,
          internalType: "bytes32",
          name: "giftId",
          type: "bytes32",
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "expireDate",
          type: "uint256",
        },
      ],
      name: "GiftCreated",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        { indexed: true, internalType: "address", name: "to", type: "address" },
        {
          indexed: false,
          internalType: "uint256",
          name: "amount",
          type: "uint256",
        },
        {
          indexed: true,
          internalType: "bytes32",
          name: "giftId",
          type: "bytes32",
        },
      ],
      name: "GiftRedeemed",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "address",
          name: "from",
          type: "address",
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "amount",
          type: "uint256",
        },
        {
          indexed: true,
          internalType: "bytes32",
          name: "giftId",
          type: "bytes32",
        },
      ],
      name: "GiftRefunded",
      type: "event",
    },
    {
      inputs: [
        { internalType: "bytes32", name: "hashedToken", type: "bytes32" },
      ],
      name: "claimGift",
      outputs: [],
      stateMutability: "payable",
      type: "function",
    },
    {
      inputs: [
        { internalType: "bytes32", name: "hashedToken", type: "bytes32" },
      ],
      name: "createGift",
      outputs: [],
      stateMutability: "payable",
      type: "function",
    },
    {
      inputs: [],
      name: "giftExpirationTime",
      outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [{ internalType: "bytes32", name: "", type: "bytes32" }],
      name: "gifts",
      outputs: [
        { internalType: "address payable", name: "sender", type: "address" },
        { internalType: "address payable", name: "claimer", type: "address" },
        { internalType: "uint256", name: "creationDate", type: "uint256" },
        { internalType: "uint256", name: "amount", type: "uint256" },
        { internalType: "bool", name: "redeemed", type: "bool" },
        { internalType: "bool", name: "refunded", type: "bool" },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "owner",
      outputs: [{ internalType: "address", name: "", type: "address" }],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        { internalType: "bytes32", name: "hashedToken", type: "bytes32" },
      ],
      name: "refundGift",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "uint256",
          name: "_newExpirationTimeInSeconds",
          type: "uint256",
        },
      ],
      name: "setExpirationTime",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
] as const;
