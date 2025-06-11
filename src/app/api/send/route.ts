import { abi } from "@/app/blockchain/abi";
import { CONTRACT_ADDRES } from "@/app/utils/config";
import {
  createMetadata,
  Metadata,
  ValidatedMetadata,
  ExecutionResponse,
} from "@sherrylinks/sdk";
import { NextRequest, NextResponse } from "next/server";
import { TransactionSerializable, encodeFunctionData } from "viem";
import { avalancheFuji } from "viem/chains";
import { serialize } from "wagmi";

export async function POST(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    const amount = searchParams.get("amount");

    if (!amount) {
      return NextResponse.json(
        { error: "Amount parameter is required" },
        {
          status: 400,
          headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type, Authorization",
          },
        }
      );
    }

    // THIS IS HOW WE ARE SUPOSSED TO SEND INFO TO THE CONTRACT
    // const data = encodeFunctionData({
    //   abi: abi,
    //   functionName: "holdCrypto",
    //   args: [amount, string(functionName)],
    // });

    return NextResponse.json({
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    });
  } catch (err) {
    console.log(err);
    return NextResponse.json(
      { error: "Failed to generate URL in send URL" },
      { status: 500 }
    );
  }
}
