-- AlterTable
ALTER TABLE "organizations" ALTER COLUMN "org_id" SET DEFAULT generate_ulid()::uuid;

-- AlterTable
ALTER TABLE "users" ALTER COLUMN "user_id" SET DEFAULT generate_ulid()::uuid;
