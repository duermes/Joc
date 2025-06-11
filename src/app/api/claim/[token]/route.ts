import { NextRequest } from "next/server";

// api/send?claim=TOKEN
// here i claimGift(token)
export async function POST(
  req: NextRequest,
  { params }: { params: { token: string } }
) {
  const token = params.token;
}
