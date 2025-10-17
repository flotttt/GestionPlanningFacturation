-- CreateEnum
CREATE TYPE "Role" AS ENUM ('Admin', 'Employe', 'Client');

-- CreateEnum
CREATE TYPE "Location" AS ENUM ('MERIGNAC', 'LA_REOLE');

-- CreateEnum
CREATE TYPE "ScheduleStatus" AS ENUM ('Prevue', 'En_cours', 'Terminee', 'Annulee');

-- CreateEnum
CREATE TYPE "ClientVisibility" AS ENUM ('visible', 'hidden');

-- CreateEnum
CREATE TYPE "InvoiceStatus" AS ENUM ('A_payer', 'Payee');

-- CreateTable
CREATE TABLE "User" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "first_name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT,
    "role" "Role" NOT NULL,
    "job" TEXT,
    "phone_number" TEXT,
    "address" TEXT,
    "failed_attempts" INTEGER NOT NULL DEFAULT 0,
    "last_failed_attempt" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "entry_date" DATE,
    "location" "Location" NOT NULL DEFAULT 'MERIGNAC',
    "disabled" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Service" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "price" DECIMAL(10,2) NOT NULL,
    "taux_tva" DECIMAL(5,2) NOT NULL DEFAULT 20.00,

    CONSTRAINT "Service_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Schedule" (
    "id" SERIAL NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "client_id" INTEGER NOT NULL,
    "date" DATE NOT NULL,
    "start_time" TIME NOT NULL,
    "end_time" TIME NOT NULL,
    "service_id" INTEGER NOT NULL,
    "status" "ScheduleStatus" NOT NULL,
    "client_visibility" "ClientVisibility" NOT NULL DEFAULT 'visible',
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "taux_applique" DECIMAL(10,2),
    "factured" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "Schedule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Invoice" (
    "id" SERIAL NOT NULL,
    "numero" TEXT NOT NULL,
    "client_id" INTEGER NOT NULL,
    "date_emission" DATE NOT NULL,
    "date_echeance" DATE NOT NULL,
    "periode_debut" DATE NOT NULL,
    "periode_fin" DATE NOT NULL,
    "montant_ht" DECIMAL(10,2) NOT NULL,
    "montant_tva" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "montant_ttc" DECIMAL(10,2) NOT NULL,
    "taux_tva" DECIMAL(5,2) NOT NULL DEFAULT 20.00,
    "status" "InvoiceStatus" NOT NULL DEFAULT 'A_payer',
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Invoice_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "InvoiceItem" (
    "id" SERIAL NOT NULL,
    "invoice_id" INTEGER NOT NULL,
    "schedule_id" INTEGER NOT NULL,
    "description" TEXT NOT NULL,
    "date_prestation" DATE NOT NULL,
    "heures" DECIMAL(5,2) NOT NULL,
    "taux_horaire" DECIMAL(10,2) NOT NULL,
    "montant_ht" DECIMAL(10,2) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "taux_tva" DECIMAL(5,2) NOT NULL DEFAULT 20.00,
    "montant_tva" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "montant_ttc" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "serviceId" INTEGER,

    CONSTRAINT "InvoiceItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ClientServiceRate" (
    "id" SERIAL NOT NULL,
    "client_id" INTEGER NOT NULL,
    "service_id" INTEGER NOT NULL,
    "taux_horaire" DECIMAL(10,2) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ClientServiceRate_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "Schedule_employee_id_idx" ON "Schedule"("employee_id");

-- CreateIndex
CREATE INDEX "Schedule_client_id_idx" ON "Schedule"("client_id");

-- CreateIndex
CREATE INDEX "Schedule_service_id_idx" ON "Schedule"("service_id");

-- CreateIndex
CREATE INDEX "Schedule_factured_idx" ON "Schedule"("factured");

-- CreateIndex
CREATE UNIQUE INDEX "Invoice_numero_key" ON "Invoice"("numero");

-- CreateIndex
CREATE INDEX "idx_client" ON "Invoice"("client_id");

-- CreateIndex
CREATE INDEX "idx_numero" ON "Invoice"("numero");

-- CreateIndex
CREATE INDEX "idx_status" ON "Invoice"("status");

-- CreateIndex
CREATE UNIQUE INDEX "InvoiceItem_schedule_id_key" ON "InvoiceItem"("schedule_id");

-- CreateIndex
CREATE INDEX "idx_invoice" ON "InvoiceItem"("invoice_id");

-- CreateIndex
CREATE UNIQUE INDEX "ClientServiceRate_client_id_service_id_key" ON "ClientServiceRate"("client_id", "service_id");

-- AddForeignKey
ALTER TABLE "Schedule" ADD CONSTRAINT "Schedule_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Schedule" ADD CONSTRAINT "Schedule_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Schedule" ADD CONSTRAINT "Schedule_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "Service"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InvoiceItem" ADD CONSTRAINT "InvoiceItem_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "Invoice"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InvoiceItem" ADD CONSTRAINT "InvoiceItem_schedule_id_fkey" FOREIGN KEY ("schedule_id") REFERENCES "Schedule"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InvoiceItem" ADD CONSTRAINT "InvoiceItem_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES "Service"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ClientServiceRate" ADD CONSTRAINT "ClientServiceRate_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ClientServiceRate" ADD CONSTRAINT "ClientServiceRate_service_id_fkey" FOREIGN KEY ("service_id") REFERENCES "Service"("id") ON DELETE CASCADE ON UPDATE CASCADE;
