extension Internal {
    static func primitiveRoot(_ n: Int) -> Int {
        switch n {
        case 2: return 1
        case 167772161, 469762049, 998244353: return 3
        case 754974721: return 11
        default: break
        }
        var divs = [Int](repeating: 0, count: 20)
        divs[0] = 2
        var count = 1
        var x = (n - 1) / 2
        while x % 2 == 0 { x /= 2 }
        var i = 3
        while i * i <= x { defer { i += 2 }
            if x % i == 0 {
                divs[count] = i
                i += 1
                while x % i == 0 {
                    x /= i
                }
            }
        }
        if x > 1 {
            divs[count] = x
            count += 1
        }
        var g = 2
        while true { defer { g += 1 }
            var ok = true
            for i in 0 ..< count {
                if powMod(g, to: (n - 1) / divs[i], mod: n) == 1 {
                    ok = false
                    break
                }
            }
            if ok { return g }
        }
    }
}
