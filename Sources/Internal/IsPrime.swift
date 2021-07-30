extension Internal {
    /// Fast Primality Testing for Integers That Fit into a Machine Word
    /// # Reference
    /// M. Forisek and J. Jancina
    /// - Parameter n: n >= 0
    func isPrime(_ n: Int) -> Bool {
        assert(n >= 0)
        if n <= 1 { return false }
        if n == 2 || n == 7 || n == 61 { return true }
        if n % 2 == 0 { return false }
        var d = n - 1
        while d % 2 == 0 { d /= 2 }
        for a in [2, 7, 61] {
            var t = d
            var y = powMod(a, to: t, mod: n)
            while t != n - 1 && y != 1 && y != n - 1 {
                y = y * y % n
                t <<= 1
            }
            if y != n - 1 && t % 2 == 0 { return false }
        }
        return true
    }
}
