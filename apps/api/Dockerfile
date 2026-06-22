# Stage 1: Build
FROM node:20-alpine AS builder
RUN apk add --no-cache libc6-compat
RUN npm install -g pnpm

WORKDIR /app

# Copy workspace configuration and locks
COPY pnpm-workspace.yaml pnpm-lock.yaml package.json ./
COPY packages/ ./packages/
COPY apps/api/package.json ./apps/api/

# Install all dependencies (including devDependencies)
RUN pnpm install --frozen-lockfile

# Copy the API source code
COPY apps/api/ ./apps/api/

# Run Prisma client generation and build the API
WORKDIR /app/apps/api
RUN pnpm prisma:generate
RUN pnpm build

# Stage 2: Run
FROM node:20-alpine AS runner
RUN apk add --no-cache libc6-compat font-noto font-noto-emoji
RUN npm install -g pnpm

WORKDIR /app

# Copy configurations and metadata
COPY pnpm-workspace.yaml pnpm-lock.yaml package.json ./
COPY packages/ ./packages/
COPY apps/api/package.json ./apps/api/
COPY --from=builder /app/apps/api/dist ./apps/api/dist
COPY --from=builder /app/apps/api/prisma ./apps/api/prisma
COPY apps/api/scripts ./apps/api/scripts
COPY apps/api/tsconfig.json ./apps/api/tsconfig.json

# Install production dependencies only
RUN pnpm install --prod --frozen-lockfile

# Expose NestJS default staging port
EXPOSE 3000
WORKDIR /app/apps/api

CMD ["pnpm", "start"]
