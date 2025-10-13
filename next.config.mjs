import bundleAnalyzer from '@next/bundle-analyzer';
import createNextIntlPlugin from 'next-intl/plugin';

// Optional: pass the path to your request config or an options object
// const withNextIntl = createNextIntlPlugin('./src/i18n/request.ts');
const withNextIntl = createNextIntlPlugin();

const withBundleAnalyzer = bundleAnalyzer({
  enabled: process.env.ANALYZE === 'true',
});

const nextConfig = {
  reactStrictMode: false,
  eslint: { ignoreDuringBuilds: true },
  images: {unoptimized: true}, // addition for handeling lib errors on old server
  webpack: (config) => {
    config.resolve.alias = {
      ...config.resolve.alias,
    };
    return config;
  },
  output: 'standalone', // Reduce docker image size
};

export default withBundleAnalyzer(withNextIntl(nextConfig));


