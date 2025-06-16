import { abi } from "@/app/blockchain/abi";
import { CONTRACT_ADDRES } from "@/app/utils/config";
import { hashToken } from "@/app/utils/yes";
import {
  createMetadata,
  Metadata,
  ValidatedMetadata,
  ExecutionResponse,
} from "@sherrylinks/sdk";
import { NextRequest, NextResponse } from "next/server";
import { TransactionSerializable, encodeFunctionData, parseEther } from "viem";
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

    const token = hashToken();
    const data = encodeFunctionData({
      abi: abi,
      functionName: "createGift",
      args: [token],
    });

    // grande lorena poniendo nombre muy descriptivos
    const tx: TransactionSerializable = {
      to: CONTRACT_ADDRES,
      data: data,
      chainId: avalancheFuji.id,
      type: `legacy`,
      value: parseEther(amount),
    };
    const serialized = serialize(tx);

    const resp: ExecutionResponse = {
      serializedTransaction: serialized,
      chainId: avalancheFuji.name,
    };

    const host = req.headers.get("host") || "localhost:3000";
    const protocol = req.headers.get("x-forwarded-proto") || "http";

    const url = `${protocol}://${host}/claim/${token}`;

    return NextResponse.json(
      { resp },
      {
        status: 200,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type, Authorization",
        },
      }
    );
  } catch (err) {
    console.log(err);
    return NextResponse.json(
      { error: "Failed to generate URL in send URL" },
      { status: 500 }
    );
  }
}
