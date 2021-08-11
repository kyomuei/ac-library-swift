
protocol Monoid {
    associatedtype SetType
    static var identity: SetType { get }
    static func operate(_ lhs: SetType, _ rhs: SetType) -> SetType
    
}

struct SetmentTree<M: Monoid> {
    private let vertexCount: Int
    private let treeSize: Int
    private let depth: Int
    private var vertices: [M.SetType]
    
    private mutating func update(_ v: Int) {
        vertices[v] = M.operate(vertices[2 * v], vertices[2 * v + 1])
    }
    
    init(vertex: [M.SetType]) {
        self.vertexCount = vertex.count
        self.depth = Internal.ceilPow2(vertex.count)
        self.treeSize = 1 << depth
        self.vertices = [M.SetType](repeating: M.identity, count: 2 * treeSize)
        for i in vertex.indices {
            vertices[treeSize + i] = vertex[i]
        }
        for i in (1 ..< treeSize).reversed() {
            update(i)
        }
    }
    
    subscript(index: Int) -> M.SetType {
        get { assert(0 <= index && index < vertexCount)
            return vertices[treeSize + index]
        }
        set { assert(0 <= index && index < vertexCount)
            let pos = index + treeSize
            vertices[pos] = newValue
            for i in 1 ... depth { update(pos >> i) }
        }
    }
    
    func allProduct() -> M.SetType { return vertices[1] }
    
    func product(in range: Range<Int>) -> M.SetType {
        assert(0 <= range.lowerBound && range.upperBound <= vertexCount)
        var sml = M.identity, smr = M.identity
        var left = range.lowerBound
        var right = range.upperBound
        while left < right {
            if left & 1 != 0 {
                sml = M.operate(sml, vertices[left])
                left += 1
            }
            if right & 1 != 0 {
                right -= 1
                smr = M.operate(vertices[right], smr)
            }
            left >>= 1
            right >>= 1
        }
        return M.operate(sml, smr)
    }
    
    func maxRight(_ left: Int, _ function: (M.SetType) -> Bool) -> Int {
        assert(0 <= left && left <= vertexCount)
        assert(function(M.identity))
        
        if left == vertexCount { return vertexCount }
        var left = left + treeSize
        var sm = M.identity
        
        repeat {
            while left & 1 == 0 { left >>= 1 }
            if !function(M.operate(sm, vertices[left])) {
                while left < treeSize {
                    left = 2 * left
                    if function(M.operate(sm, vertices[left])) {
                        sm = M.operate(sm, vertices[left])
                        left += 1
                    }
                }
                return left - treeSize
            }
            sm = M.operate(sm, vertices[left])
            left += 1
        } while left & -left != left
        
        return vertexCount
    }
    
    func minLeft(_ right: Int, _ function: (M.SetType) -> Bool) -> Int {
        assert(0 <= right && right <= vertexCount)
        assert(function(M.identity))
        
        if right == 0 { return 0 }
        var right = right + treeSize
        var sm = M.identity
        
        repeat {
            right -= 1
            while right > 1 && right & 1 != 0 { right >>= 1 }
            if !function(M.operate(vertices[right], sm)) {
                while right < treeSize {
                    right = 2 * right + 1
                    if function(M.operate(vertices[right], sm)) {
                        sm = M.operate(vertices[right], sm)
                        right -= 1
                    }
                }
                return right + 1 - treeSize
            }
            sm = M.operate(vertices[right], sm)
        } while right & -right != right
        
        return 0
    }
}
