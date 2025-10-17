/*
  Warnings:

  - You are about to drop the column `serviceId` on the `InvoiceItem` table. All the data in the column will be lost.
  - Added the required column `service_id` to the `InvoiceItem` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "public"."InvoiceItem" DROP CONSTRAINT "InvoiceItem_serviceId_fkey";

-- AlterTable
ALTER TABLE "InvoiceItem" DROP COLUMN "serviceId",
ADD COLUMN     "service_id" INTEGER NOT NULL;

-- AddForeignKey
ALTER TABLE "InvoiceItem" ADD CONSTRAINT "InvoiceItem_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "Service"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
