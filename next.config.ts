import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  crossOrigin: "anonymous",
  eslint: {
    ignoreDuringBuilds: true,
  },
};

export default nextConfig;
