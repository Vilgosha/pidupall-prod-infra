FROM node:24-alpine AS builder 

WORKDIR /app

COPY . .

RUN yarn install --immutable 

RUN yarn build



FROM node:24-alpine AS runner

WORKDIR /app

RUN corepack enable &&\
    corepack prepare yarn@4.9.2 --activate

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy only the standalone build output
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

# Change ownership
RUN chown -R nextjs:nodejs /app
USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
