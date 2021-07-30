extension Internal {
    func safeMod(_ x: Int, mod: Int) -> Int {
        let x = x % mod
        return x < 0 ? x + mod : x
    }
}
