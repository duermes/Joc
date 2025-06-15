import { randomBytes } from "crypto";
import { keccak256 } from "viem";

export function hashToken() {
  const buf = randomBytes(32);
  return keccak256(buf);
}
export function compareTokens() {}
