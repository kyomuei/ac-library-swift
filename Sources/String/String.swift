struct SuffixArray {
    var source: [Int] = []
    var value: [Int] = []

    init(_ s: [Int], upper: Int) {
        assert(upper >= 0)
        assert(s.allSatisfy { 0 <= $0 && $0 <= upper })
        source = s
        value = inducedSorting(s, upper: upper)
    }

    init<T>(_ s: [T]) where T: FixedWidthInteger {
        let idx = s.indices.sorted { s[$0] < s[$1] }
        var s2 = [Int](repeating: 0, count: s.count)
        var now = 0
        for i in s.indices {
            if i != 0 && s[idx[i - 1]] != s[idx[i]] { now += 1 }
            s2[idx[i]] = now
        }
        source = s2
        value = inducedSorting(s2, upper: now)
    }

    init(_ s: String) {
        source = s.map { Int($0.asciiValue!) }
        value = inducedSorting(source, upper: 255)
    }

    func naive(_ s: [Int]) -> [Int] {
        return s.indices.sorted {
            var left = $0, right = $1
            if left == right { return false }
            while left < s.count && right < s.count {
                if s[left] != s[right] { return s[left] < s[right] }
                left += 1
                right += 1
            }
            return left == s.count
        }
    }

    func doubling(_ s: [Int]) -> [Int] {
        var sa = Array(s.indices)
        var rank = s
        var tmp = [Int](repeating: 0, count: s.count)
        var k = 1
        while k < s.count { defer { k *= 2 }
            let cmp = { (x: Int, y: Int) -> Bool in 
                if rank[x] != rank[y] { return rank[x] < rank[y] }
                let rx = x + k < s.count ? rank[x + k] : -1
                let ry = y + k < s.count ? rank[y + k] : -1
                return rx < ry
            }
            sa.sort(by: cmp)
            tmp[sa[0]] = 0
            for i in 0 ..< (s.count - 1) {
                tmp[sa[i]] = tmp[sa[i]] + (cmp(sa[i], sa[i + 1]) ? 1 : 0)
            }
            swap(&tmp, &rank)
        }
        return sa
    }

    /// SA-IS, linear-time suffix array construction
    ///
    /// Two Efficient Algorithms for Linear Time Suffix Array Construction
    /// # Reference
    /// G. Nong, S. Zhang, and W. H. Chan,
    func inducedSorting(
        _ s: [Int], upper: Int,
        threshold: (naive: Int, doubling: Int) = (10, 40)) -> [Int] {
        switch s.count {
        case 0: return []
        case 1: return [0]
        case 2: return s[0] < s[1] ? [0, 1] : [1, 0]
        default: break
        }
        if s.count < threshold.naive { return naive(s) }
        if s.count < threshold.doubling { return doubling(s) }

        var sa = [Int](repeating: 0, count: s.count)
        var ls = [Bool](repeating: false, count: s.count)

        for i in (0 ..< (s.count - 1)).reversed() {
            ls[i] = s[i] == s[i + 1] ? ls[i + 1] : (s[i] < s[i + 1])
        }
        var sumL = [Int](repeating: 0, count: upper + 1)
        var sumS = [Int](repeating: 0, count: upper + 1)
        for i in s.indices {
            ls[i] ? (sumL[s[i] + 1] += 1) : (sumS[s[i]] += 1)
        }
        for i in 0 ... upper {
            sumS[i] += sumL[i]
            if i < upper { sumL[i + 1] += sumS[i] }
        }
        let induce = { (lms: [Int]) -> Void in 
            sa.withUnsafeMutableBufferPointer { $0.assign(repeating: -1) }
            var buffer = [Int](repeating: 0, count: upper + 1)
            buffer.withUnsafeMutableBufferPointer { _ = $0.initialize(from: sumS) }
            for d in lms {
                if d == s.count { continue }
                sa[buffer[s[d]]] = d
                buffer[s[d]] += 1
            }
            buffer.withUnsafeMutableBufferPointer { _ = $0.initialize(from: sumL) }
            sa[buffer[s[s.count - 1]]] = s.count - 1
            buffer[s[s.count - 1]] += 1
            for i in s.indices {
                let v = sa[i]
                if v >= 1 && !ls[v - 1] {
                    sa[buffer[s[v - 1]]] = v - 1
                    buffer[s[v - 1]] += 1
                }
            }
            buffer.withUnsafeMutableBufferPointer { _ = $0.initialize(from: sumL) }
            for i in s.indices.reversed() {
                let v = sa[i]
                if v >= 1 && ls[v - 1] {
                    buffer[s[v - 1] + 1] -= 1
                    sa[buffer[s[v - 1] + 1]] = v - 1
                }
            }
        }
        var lmsMap = [Int](repeating: -1, count: s.count + 1)
        var m = 0
        for i in 0 ..< (s.count - 1) {
            if !ls[i] && ls[i + 1] {
                lmsMap[i] = m
                m += 1
            }
        }
        var lms = [Int]()
        lms.reserveCapacity(m)
        for i in 0 ..< (s.count - 1) {
            if !ls[i] && ls[i + 1] {
                lms.append(i)
            }
        }
        induce(lms)
        if m == 0 { return sa }
        var sortedLms = [Int]()
        sortedLms.reserveCapacity(m)
        for v in sa {
            if lmsMap[v] != -1 { sortedLms.append(v) }
        }
        var recS = [Int](repeating: 0, count: m)
        var recUpper = 0
        recS[lmsMap[sortedLms[0]]] = 0
        for i in 1 ..< m {
            var left = sortedLms[i - 1], right = sortedLms[i]
            let endL = lmsMap[left] + 1 < m ? lms[lmsMap[left] + 1] : s.count
            let endR = lmsMap[right] + 1 < m ? lms[lmsMap[right] + 1] : s.count
            var isSame = true
            if endL - left != endR - right {
                isSame = false 
            } else {
                while left < endL {
                    if s[left] != s[right] { break }
                    left += 1
                    right += 1
                }
                if left == s.count || s[left] != s[right] { isSame = false }
            }
            if !isSame { recUpper += 1 }
            recS[lmsMap[sortedLms[i]]] = recUpper
        }
        let recSA = inducedSorting(recS, upper: recUpper)
        for i in 0 ..< m {
            sortedLms[i] = lms[recSA[i]]
        }
        induce(sortedLms)
        return sa
    }
}

extension SuffixArray {
    
    /// Linear-Time Longest-Common-Prefix Computation in Suffix Arrays 
    /// and Its Applications
    /// # Reference
    /// T. Kasai, G. Lee, H. Arimura, S. Arikawa, and K. Park,
    func lcpArray() -> [Int] {
        assert(source.count >= 1)
        var rank = [Int](repeating: 0, count: source.count)
        for i in value.indices { rank[value[i]] = i }
        var lcp = [Int](repeating: 0, count: source.count - 1)
        var h = 0
        for i in rank.indices {
            if h > 0 { h -= 1 }
            if rank[i] == 0 { continue }
            let j = value[rank[i] - 1]
            while j + h < rank.count && i + h < rank.count {
                if source[j + h] != source[i + h] { break }
                h += 1
            }
            lcp[rank[i] - 1] = h
        }
        return lcp
    }
}


/// Algorithms on Strings, Trees, and Sequences: 
/// Computer Science and Computational Biology
/// # Reference
/// D. Gusfield,
func ZAlgorithm<T>(_ s: [T]) -> [Int] where T: FixedWidthInteger {
    if s.isEmpty { return [] }
    var z = [Int](repeating: 0, count: s.count)
    var j = 0
    for i in 1 ..< s.count {
        z[i] = j + z[j] <= i ? 0 : min(j + z[j] - i, z[i - j])
        while i + z[i] < s.count && s[z[i]] == s[i + z[i]] { z[i] += 1 }
        if j + z[j] < i + z[i] { j = i }
    }
    z[0] = s.count
    return z
}

func ZAlgorithm(_ s: String) -> [Int] {
    ZAlgorithm(s.map { $0.asciiValue! })
}
