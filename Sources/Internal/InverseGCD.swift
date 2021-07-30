extension Internal {
    func inverseGCD(_ a: Int, _ b: Int) -> (mod: Int, inverse: Int) {
        var s = b, t = safeMod(a, mod: b)
        if t == 0 { return (b, 0) }
        var m0 = 0, m1 = 1
        while t > 0 {
            let u = s / t
            s -= t * u
            m0 -= m1 * u
            swap(&s, &t)
            swap(&m0, &m1)
        }
        if m0 < 0 { m0 += b / s }
        return (s, m0)
    }
}
