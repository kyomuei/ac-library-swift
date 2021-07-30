/// Data structures and algorithms for disjoint set union problems
/// 
/// Implement (union by size) + (path compression)
/// # Reference
/// Zvi Galil and Giuseppe F. Italiano
struct DSU {
    /// if the vertex is root, the value is -1 * component size;
    /// otherwise, the value is parent index.
    private var vertices: [Int]

    init(vertexCount: Int) {
        vertices = [Int](repeating: -1, count: vertexCount)
    }

    mutating func leader(of v: Int) -> Int {
        assert(vertices.indices.contains(v))
        if vertices[v] < 0 { return v }
        vertices[v] = leader(of: vertices[v])
        return vertices[v]
    }

    mutating func isSame(_ u: Int, _ v: Int) -> Bool {
        assert(vertices.indices.contains(u))
        assert(vertices.indices.contains(v))
        return leader(of: u) == leader(of: v)
    }

    mutating func merge(_ u: Int, _ v: Int) -> Int {
        assert(vertices.indices.contains(u))
        assert(vertices.indices.contains(v))
        var x = leader(of: u), y = leader(of: v)
        if x == y { return x }
        if -vertices[x] < -vertices[y] { swap(&x, &y) }
        vertices[x] += vertices[y]
        vertices[y] = x
        return x
    }

    func groupSize(_ member: Int) -> Int {
        assert(vertices.indices.contains(member))
        return -vertices[member]
    }

    mutating func groups() -> [[Int]] {
        var leaders = [Int](repeating: 0, count: vertices.count)
        var groups = [Int](repeating: 0, count: vertices.count)
        for i in vertices.indices {
            leaders[i] = leader(of: i)
            groups[leaders[i]] += 1
        }
        var result = [[Int]](repeating: [], count: vertices.count)
        for i in leaders.indices {
            result[leaders[i]].append(i)
        }
        return result.filter { !$0.isEmpty }
    }
}
