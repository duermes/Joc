import {
  createMetadata,
  Metadata,
  ValidatedMetadata,
  ExecutionResponse,
} from "@sherrylinks/sdk";
import { NextRequest, NextResponse } from "next/server";
import { avalancheFuji } from "viem/chains";
import { serialize } from "wagmi";

export async function POST(req: NextRequest) {
  try {
    // Extract parameters
    const { searchParams } = new URL(req.url);
    const amount = searchParams.get("amount");

    // Validate required parameters
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

    // Transaction creation will be added next
  } catch (err) {
    console.log(err);
    return NextResponse.json(
      { error: "Failed to generate URL in request" },
      { status: 500 }
    );
  }
}
