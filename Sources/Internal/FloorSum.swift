extension Internal {
    /// - Parameters:
    ///     - n: `n < 2^32`
    ///     - m: `1 <= m < 2^32`
    static func floorSum(_ n: Int, _ m: Int, _ a: Int, _ b: Int) -> UInt {
        var answer: UInt = 0
        var n = UInt(n)
        var m = UInt(m)
        var a = UInt(a)
        var b = UInt(b)

        while true {
            if a >= m {
                answer += n * (n - 1) / 2 * (a / m)
                a %= m
            }
            if b >= m {
                answer += n * (b / m)
                b %= m
            }
            let ymax = a * n + b
            if ymax < m { break }
            n = ymax / m
            b = ymax % m
            swap(&m, &a)
        }
        return answer
    }
}
