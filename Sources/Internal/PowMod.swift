extension Internal {
    /// - Parameters:
    ///     - n: n >= 0
    ///     - mod: mod > 0
    static func powMod(_ x: Int, to n: Int, mod: Int) -> Int {
        assert(n >= 0)
        assert(mod > 0)
        if mod == 1 { return 0 }
        let umod = UInt(mod)
        var r: UInt = 1
        var y: UInt = UInt(safeMod(x, mod: mod))
        var t = n
        while t > 0 {
            if t & 1 != 0 { r = (r * y) % umod }
            y = (y * y) % umod
            t >>= 1
        }
        return Int(r)
    }
}
