extension Internal {
    /// Fast modular multiplication by barrett reduction
    /// # Reference
    /// https://en.wikipedia.org/wiki/Barrett_reduction
    /// - NOTE: reconsider after Ice Lake
    struct Barrett {
        let mod: Int
        let inverseMod: UInt

        init(mod: Int) {
            assert(0 < mod && mod < (1 << 31) )
            self.mod = mod
            inverseMod = mod == 1 ? 0 : (UInt.max / UInt(mod) + 1)
        }

        func multiply(_ a: Int, _ b: Int) -> Int {
            assert(0 <= a && a < self.mod)
            assert(0 <= b && b < self.mod)
            let z = UInt(a) * UInt(b)
            let x = z.multipliedFullWidth(by: inverseMod).high
            let v = Int(z - x * UInt(mod))
            return mod <= v ? v + mod : v
        }
    }
}
