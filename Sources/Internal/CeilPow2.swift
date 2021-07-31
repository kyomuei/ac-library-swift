extension Internal {
    /// - Parameter n: n >= 0
    static func ceilPow2(_ n: Int) -> Int {
        var x = 0
        while (1 << x) < n { x += 1 }
        return x
    }
}
