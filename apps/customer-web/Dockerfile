# Stage 1: Build
FROM node:20-alpine AS builder
RUN apk add --no-cache libc6-compat
RUN npm install -g pnpm

WORKDIR /app

# Copy workspace configuration and locks
COPY pnpm-workspace.yaml pnpm-lock.yaml package.json ./
COPY packages/ ./packages/
COPY apps/customer-web/package.json ./apps/customer-web/

# Install all dependencies (including devDependencies)
RUN pnpm install --frozen-lockfile

# Copy the customer-web source code
COPY apps/customer-web/ ./apps/customer-web/

# Set Next.js environment variables required at build time
ARG NEXT_PUBLIC_ENABLE_APPLE_WALLET_BUTTON=true
ENV NEXT_PUBLIC_ENABLE_APPLE_WALLET_BUTTON=${NEXT_PUBLIC_ENABLE_APPLE_WALLET_BUTTON}

# Run the production build
WORKDIR /app/apps/customer-web
RUN pnpm build

# Stage 2: Run
FROM node:20-alpine AS runner
RUN apk add --no-cache libc6-compat
RUN npm install -g pnpm

WORKDIR /app

# Copy configurations and metadata
COPY pnpm-workspace.yaml pnpm-lock.yaml package.json ./
COPY packages/ ./packages/
COPY apps/customer-web/package.json ./apps/customer-web/
COPY --from=builder /app/apps/customer-web/.next ./apps/customer-web/.next
COPY --from=builder /app/apps/customer-web/public ./apps/customer-web/public

# Install production dependencies only
RUN pnpm install --prod --frozen-lockfile

# Expose Next.js default staging port
EXPOSE 3001
WORKDIR /app/apps/customer-web

CMD ["pnpm", "start"]
