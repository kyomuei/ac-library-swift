
func powMod(_ x: Int, to n: Int, mod: Int) -> Int {
    assert(n >= 0)
    assert(mod > 0)
    if mod == 1 { return 0 }
    let bt = Internal.Barrett(mod: mod)
    var r = 1
    var y = Internal.safeMod(x, mod: mod)
    var n = n
    while n > 0 {
        if n & 1 != 0 { r = bt.multiply(r, y) }
        y = bt.multiply(y, y)
        n >>= 1
    }
    return r
}

func inverseMod(_ x: Int, mod: Int) -> Int {
    assert(mod > 0)
    let z = Internal.inverseGCD(x, mod)
    assert(z.gcd == 1)
    return z.inverse
}

func crt(_ r: [Int], _ m: [Int]) -> (reminder: Int, mod: Int) {
    assert(r.count == m.count)
    var r0 = 0, m0 = 1
    for i in r.indices {
        assert(m[i] >= 1)
        var r1 = Internal.safeMod(r[i], mod: m[i])
        var m1 = m[i]
        if m0 < m1 {
            swap(&r0, &r1)
            swap(&m0, &m1)
        }
        if m0 % m1 == 0 {
            if r0 % m1 != r1 { return (0, 0) }
            continue
        }
        
        let (g, im) = Internal.inverseGCD(m0, m1)
        let u1 = m1 / g
        if (r1 - r0) % g != 0 { return (0, 0) }
        let x = (r1 - r0) / g % u1 * im % u1
        r0 += x * m0
        m0 *= u1
        if r0 < 0 { r0 += m0 }
    }
    return (r0, m0)
}

func floorSum(_ n: Int, _ m: Int, _ a: Int, _ b: Int) -> Int {
    assert(0 <= n && n < (1 << 32))
    assert(0 <= m && m < (1 << 32))
    var a = a, b = b
    var ans = 0
    if a < 0 {
        let a2 = Internal.safeMod(a, mod: m)
        ans -= n * (n - 1) / 2 * ((a2 - a) / m)
        a = a2
    }
    if b < 0 {
        let b2 = Internal.safeMod(b, mod: m)
        ans -= n * ((b2 - b) / m)
        b = b2
    }
    return ans + Int(Internal.floorSum(n, m, a, b))
}
