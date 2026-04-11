-- Enable pgcrypto extension for cryptographic randomness
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create ULID generation function
-- Returns a 26-character ULID string encoded as UUID
-- T = timestamp (48 bits, ms since epoch 2010-01-01), R = random (80 bits)
CREATE OR REPLACE FUNCTION generate_ulid() RETURNS uuid AS $$
DECLARE
    unix_epoch BIGINT := 1288834974657;
    now_millis BIGINT;
    timestamp_part TEXT;
    random_part TEXT;
    encoding TEXT := '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
BEGIN
    now_millis := floor(extract(epoch from clock_timestamp()) * 1000)::BIGINT;

    -- Encode timestamp (48 bits → 10 base32 chars)
    timestamp_part := (
        substr(encoding, 1 + ((now_millis - unix_epoch) >> 40) & 31, 1) ||
        substr(encoding, 1 + ((now_millis - unix_epoch) >> 35) & 31, 1) ||
        substr(encoding, 1 + ((now_millis - unix_epoch) >> 30) & 31, 1) ||
        substr(encoding, 1 + ((now_millis - unix_epoch) >> 25) & 31, 1) ||
        substr(encoding, 1 + ((now_millis - unix_epoch) >> 20) & 31, 1) ||
        substr(encoding, 1 + ((now_millis - unix_epoch) >> 15) & 31, 1) ||
        substr(encoding, 1 + ((now_millis - unix_epoch) >> 10) & 31, 1) ||
        substr(encoding, 1 + ((now_millis - unix_epoch) >> 5) & 31, 1) ||
        substr(encoding, 1 + ((now_millis - unix_epoch)) & 31, 1)
    );

    -- Encode random (80 bits → 13 base32 chars from 10 random bytes)
    random_part := (
        substr(encoding, 1 + (gen_random_bytes(6)::BIGINT >> 55) & 31, 1) ||
        substr(encoding, 1 + (gen_random_bytes(6)::BIGINT >> 50) & 31, 1) ||
        substr(encoding, 1 + (gen_random_bytes(6)::BIGINT >> 45) & 31, 1) ||
        substr(encoding, 1 + (gen_random_bytes(6)::BIGINT >> 40) & 31, 1) ||
        substr(encoding, 1 + (gen_random_bytes(6)::BIGINT >> 35) & 31, 1) ||
        substr(encoding, 1 + (gen_random_bytes(6)::BIGINT >> 30) & 31, 1) ||
        substr(encoding, 1 + (gen_random_bytes(6)::BIGINT >> 25) & 31, 1) ||
        substr(encoding, 1 + (gen_random_bytes(6)::BIGINT >> 20) & 31, 1) ||
        substr(encoding, 1 + (gen_random_bytes(6)::BIGINT >> 15) & 31, 1) ||
        substr(encoding, 1 + (gen_random_bytes(6)::BIGINT >> 10) & 31, 1) ||
        substr(encoding, 1 + (gen_random_bytes(6)::BIGINT >> 5) & 31, 1) ||
        substr(encoding, 1 + (gen_random_bytes(6)::BIGINT) & 31, 1)
    );

    RETURN (upper(timestamp_part || random_part))::uuid;
END;
$$ LANGUAGE plpgsql VOLATILE STRICT;

-- CreateEnum
CREATE TYPE "OrgPlan" AS ENUM ('FREE', 'PRO', 'ENTERPRISE');

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('ADMIN', 'MEMBER', 'VIEWER');

-- CreateTable
CREATE TABLE "organizations" (
    "org_id" UUID NOT NULL DEFAULT generate_ulid(),
    "name" TEXT NOT NULL,
    "plan" "OrgPlan" NOT NULL DEFAULT 'FREE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "organizations_pkey" PRIMARY KEY ("org_id")
);

-- CreateTable
CREATE TABLE "users" (
    "user_id" UUID NOT NULL DEFAULT generate_ulid(),
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "name" TEXT,
    "role" "UserRole" NOT NULL DEFAULT 'MEMBER',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "users_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "user_organizations" (
    "user_id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "role" "UserRole" NOT NULL DEFAULT 'MEMBER',
    "joined_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "user_organizations_pkey" PRIMARY KEY ("user_id","organization_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- AddForeignKey
ALTER TABLE "user_organizations" ADD CONSTRAINT "user_organizations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_organizations" ADD CONSTRAINT "user_organizations_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("org_id") ON DELETE RESTRICT ON UPDATE CASCADE;
