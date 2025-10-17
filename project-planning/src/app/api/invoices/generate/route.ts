import { NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'
import { addDays } from 'date-fns'

function money(n: number) { return Math.round(n * 100) / 100 }

export async function POST(req: Request) {
    const { clientId, from, to } = await req.json()
    const dateFrom = new Date(from)
    const dateTo = new Date(to)

    try {
        const result = await prisma.$transaction(async (tx) => {
            const schedules = await tx.schedule.findMany({
                where: {
                    client_id: Number(clientId),
                    status: 'Terminee',
                    date: { gte: dateFrom, lte: dateTo },
                    factured: false,
                },
                include: { service: true },
            })

            if (schedules.length === 0) {
                return { error: 'Aucune prestation terminée sur la période.' }
            }

            // Numérotation FAC-YYYY-###
            const year = new Date().getFullYear()
            const last = await tx.invoice.findFirst({
                where: { numero: { startsWith: `FAC-${year}-` } },
                orderBy: { numero: 'desc' },
            })
            const next = last ? parseInt(last.numero.split('-')[2]) + 1 : 1
            const numero = `FAC-${year}-${String(next).padStart(3, '0')}`

            let totalHt = 0
            let totalTva = 0

            const invoice = await tx.invoice.create({
                data: {
                    numero,
                    client_id: Number(clientId),
                    date_emission: new Date(),
                    date_echeance: addDays(new Date(), 30),
                    periode_debut: dateFrom,
                    periode_fin: dateTo,
                    montant_ht: 0,
                    montant_tva: 0,
                    montant_ttc: 0,
                    status: 'A_payer',
                    taux_tva: 20.0,
                }
            })

            for (const s of schedules) {
                // Dates → nombres
                const start = new Date(s.start_time as unknown as string | Date)
                const end   = new Date(s.end_time   as unknown as string | Date)
                const diffMs = end.getTime() - start.getTime()
                const hours = Math.max(0, diffMs / 36e5)
                const qty = hours > 0 ? hours : 1

                // Decimal → number
                const unit = Number(s.taux_applique ?? s.service.price)
                const vatRate = Number(s.service.taux_tva ?? 20) / 100

                const lineHt  = money(qty * unit)
                const lineTva = money(lineHt * vatRate)

                totalHt  += lineHt
                totalTva += lineTva

                await tx.invoiceItem.create({
                    data: {
                        invoice_id: invoice.id,
                        schedule_id: s.id,
                        // 🔑 on récupère l'id du service via la relation déjà incluse
                        serviceId: s.service.id,
                        description: s.service.name,
                        date_prestation: new Date(s.date as unknown as string | Date),
                        heures: qty,
                        taux_horaire: unit,
                        montant_ht: lineHt,
                        taux_tva: Number(s.service.taux_tva ?? 20),
                        montant_tva: lineTva,
                        montant_ttc: money(lineHt + lineTva),
                    }
                })

                await tx.schedule.update({
                    where: { id: s.id },
                    data: { factured: true }
                })
            }

            const updated = await tx.invoice.update({
                where: { id: invoice.id },
                data: {
                    montant_ht: money(totalHt),
                    montant_tva: money(totalTva),
                    montant_ttc: money(totalHt + totalTva),
                },
                include: { items: true, client: true }
            })

            return updated
        })

        if ('error' in result) return NextResponse.json(result, { status: 400 })
        return NextResponse.json(result, { status: 201 })
    } catch (e) {
        console.error(e)
        return NextResponse.json({ error: 'Erreur génération facture' }, { status: 500 })
    }
}