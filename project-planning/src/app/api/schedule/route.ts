import { NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'

export async function GET(req: Request) {
    const { searchParams } = new URL(req.url)
    const clientId = searchParams.get('clientId')
    const employeeId = searchParams.get('employeeId')
    const status = searchParams.get('status')
    const dateFrom = searchParams.get('from')
    const dateTo = searchParams.get('to')

    const schedules = await prisma.schedule.findMany({
        where: {
            client_id: clientId ? Number(clientId) : undefined,
            employee_id: employeeId ? Number(employeeId) : undefined,
            status: status as any || undefined,
            date: {
                gte: dateFrom ? new Date(dateFrom) : undefined,
                lte: dateTo ? new Date(dateTo) : undefined,
            },
        },
        include: { service: true, employee: true, client: true },
        orderBy: [{ date: 'asc' }, { start_time: 'asc' }],
    })

    return NextResponse.json(schedules)
}