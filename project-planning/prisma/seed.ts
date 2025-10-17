import { prisma } from '@/lib/prisma'
import bcrypt from 'bcryptjs'

async function main() {
    const admin = await prisma.user.upsert({
        where: { email: 'admin@demo.dev' },
        update: {},
        create: {
            email: 'admin@demo.dev',
            name: 'Admin',
            first_name: 'Demo',
            role: 'Admin',
            password: await bcrypt.hash('demo1234', 10),
            location: 'MERIGNAC',
        },
    })

    const client = await prisma.user.upsert({
        where: { email: 'client@acme.test' },
        update: {},
        create: {
            email: 'client@acme.test',
            name: 'Doe',
            first_name: 'Jane',
            role: 'Client',
            location: 'MERIGNAC',
        },
    })

    const employe = await prisma.user.upsert({
        where: { email: 'employee@demo.dev' },
        update: {},
        create: {
            email: 'employee@demo.dev',
            name: 'Durand',
            first_name: 'Paul',
            role: 'Employe',
            location: 'MERIGNAC',
        },
    })

    const service = await prisma.service.upsert({
        where: { id: 1 },
        update: {},
        create: { name: 'Prestation standard', price: 60.00, taux_tva: 20.00 },
    })

    const today = new Date()
    const dateISO = new Date(today.toDateString()) // jour sans l’heure
    await prisma.schedule.create({
        data: {
            employee_id: employe.id,
            client_id: client.id,
            date: dateISO,
            start_time: new Date(dateISO.getTime() + 9 * 3600 * 1000),
            end_time: new Date(dateISO.getTime() + 17 * 3600 * 1000),
            service_id: service.id,
            status: 'Terminee',
            factured: false,
            taux_applique: 60.0,
        },
    })
}

main().then(() => prisma.$disconnect())
    .catch(async (e) => { console.error(e); await prisma.$disconnect(); process.exit(1) })