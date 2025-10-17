export function assertRole(user: { role: string } | null | undefined, roles: string[]) {
    if (!user || !roles.includes(user.role)) {
        const err = new Error('Forbidden')
        ;(err as any).status = 403
        throw err
    }
}