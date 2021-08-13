
/// # Reference
/// [wikipedia](https://en.wikipedia.org/wiki/Fenwick_tree)
struct FenwickTree<T: FixedWidthInteger> {
    typealias U = T.Magnitude
    
    private var data: [U]
    
    private func sum(_ r: Int) -> U {
        var s: U = 0
        var r = r
        while r > 0 {
            s += data[r - 1]
            r -= r & -r
        }
        return s
    }
    
    init(count: Int) {
        data = [U](repeating: 0, count: count)
    }
    
    mutating func add(_ value: T, to index: Int) {
        assert(data.indices.contains(index))
        var pos = index + 1
        while pos <= data.count {
            data[pos - 1] += U(value)
            pos += pos & -pos
        }
    }
    
    func sum(in range: Range<Int>) -> T {
        assert(0 <= range.lowerBound && range.upperBound <= data.count)
        return T(sum(range.upperBound) - sum(range.lowerBound))
    }
}
