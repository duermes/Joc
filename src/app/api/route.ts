import { createMetadata, Metadata, ValidatedMetadata } from "@sherrylinks/sdk";
import { NextRequest, NextResponse } from "next/server";

// example bro, you might need to move this somewhere (or not)
export async function GET(req: NextRequest) {
  try {
    const host = req.headers.get("host") || "localhost:3000";
    const protocol = req.headers.get("x-forwarded-proto") || "http";

    const serverUrl = `${protocol}://${host}`;

    const metadata: Metadata = {
      url: "https://sherry.social",
      icon: "https://avatars.githubusercontent.com/u/117962315",
      title: "JOC",
      baseUrl: serverUrl,
      description:
        "Application to be able to send crypto anywhere! Like gifts!",
      actions: [
        {
          type: "dynamic",
          label: "Send",
          description: "Send money",
          chains: { source: "fuji" }, // fuji es el testnet de avalanche
          path: `/api/send`,
          params: [
            {
              name: "amount",
              label: "amount to send",
              type: "number",
              required: true,
              description: "Enter the amount of money you want to send",
            },
          ],
        },
        {
          type: "dynamic",
          label: "Request",
          description: "Request money",
          chains: { source: "fuji" },
          path: `/api/request`,
          params: [
            {
              name: "amount",
              label: "amount to request",
              type: "number",
              required: true,
              description: "Enter the amount of money you want to request",
            },
          ],
        },
      ],
    };
    const validated: ValidatedMetadata = createMetadata(metadata);
    return NextResponse.json(validated, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
      },
    });
  } catch (err) {
    console.log(`Error creating metadata: ${err}`);
    return NextResponse.json(
      { error: "Failed to create metadata" },
      { status: 500 }
    );
  }
}
