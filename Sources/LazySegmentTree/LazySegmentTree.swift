
protocol MonoidMap {
    associatedtype SetType
    associatedtype Target
    
    static var identity: SetType { get }
    static func operate(_ lhs: SetType, _ rhs: SetType) -> SetType
    
    static func mapping(_ lhs: Target, _ rhs: SetType) -> SetType
    static func composite(_ lhs: Target, _ rhs: Target) -> Target
    static func identicalMap() -> Target
}

struct LazySegmentTree<M: MonoidMap> {
    private let vertexCount: Int
    private let depth: Int
    private let treeSize: Int
    private var vertices: [M.SetType]
    private var lazyData: [M.Target]
    
    private mutating func update(_ v: Int) {
        vertices[v] = M.operate(vertices[2 * v], vertices[2 * v + 1])
    }
    
    private mutating func allApply(_ v: Int, _ f: M.Target) {
        vertices[v] = M.mapping(f, vertices[v])
        if v < treeSize {
            lazyData[v] = M.composite(f, lazyData[v])
        }
    }
    
    private mutating func push(_ v: Int) {
        allApply(2 * v, lazyData[v])
        allApply(2 * v + 1, lazyData[v])
        lazyData[v] = M.identicalMap()
    }
    
    init(vertexCount: Int) {
        self.init(vertices: [M.SetType](repeating: M.identity, count: vertexCount))
    }
    
    init(vertices: [M.SetType]) {
        self.vertexCount = vertices.count
        self.depth = Internal.ceilPow2(vertices.count)
        self.treeSize = 1 << depth
        self.vertices = [M.SetType](repeating: M.identity, count: 2 * treeSize)
        self.lazyData = [M.Target](repeating: M.identicalMap(), count: treeSize)
        for i in vertices.indices {
            self.vertices[treeSize + i] = vertices[i]
        }
        for i in (1 ..< treeSize).reversed() {
            update(i)
        }
    }
    
    subscript(index: Int) -> M.SetType {
        get { assert(0 <= index && index < vertexCount)
            let pos = index + treeSize
            return vertices[pos]
        }
        set { assert(0 <= index && index < vertexCount)
            let pos = index + treeSize
            for i in (1 ... depth).reversed() {
                push(pos >> i)
            }
            vertices[pos] = newValue
            for i in 1 ... depth {
                update(pos >> i)
            }
        }
    }
    
    func allProduct() -> M.SetType { return vertices[1] }
    
    mutating func product(in range: Range<Int>) -> M.SetType {
        assert(0 <= range.lowerBound && range.upperBound <= vertexCount)
        if range.lowerBound == range.upperBound { return M.identity}
        
        var left = range.lowerBound + treeSize
        var right = range.upperBound + treeSize
        
        for i in (1 ... depth).reversed() {
            if ((left >> i) << i) != left { push(left >> i) }
            if ((right >> i) << i) != right { push((right - 1) >> i) }
        }
        
        var sml = M.identity, smr = M.identity
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
    
    mutating func apply(to index: Int, value: M.Target) {
        assert(0 <= index && index < vertexCount)
        let pos = index + treeSize
        for i in (1 ... depth).reversed() {
            push(pos >> i)
        }
        vertices[pos] = M.mapping(value, vertices[pos])
        for i in 1 ... depth {
            update(pos >> i)
        }
    }
    
    mutating func apply(in range: Range<Int>, value: M.Target) {
        assert(0 <= range.lowerBound && range.upperBound <= vertexCount)
        if range.count == 0 { return }
        
        var left = range.lowerBound + treeSize
        var right = range.upperBound + treeSize
        
        for i in (1 ... depth).reversed() {
            if ((left >> i) << i) != left { push(left >> i) }
            if ((right >> i) << i) != right { push((right - 1) >> i) }
        }
        
        while left < right {
            if left & 1 != 0 {
                allApply(left, value)
                left += 1
            }
            if right & 1 != 0 {
                right -= 1
                allApply(right, value)
            }
        }
        
        left = range.lowerBound + treeSize
        right = range.upperBound + treeSize
        
        for i in 1 ... depth {
            if ((left >> i) << i) != left { update(left >> i) }
            if ((right >> i) << i) != right { update((right - 1) >> i) }
        }
    }
    
    mutating func maxRight(_ left: Int, _ function: (M.SetType) -> Bool) -> Int {
        assert(0 <= left && left <= vertexCount)
        assert(function(M.identity))
        if left == vertexCount { return vertexCount }
        var left = left + treeSize
        for i in (1 ... depth).reversed() {
            push(left >> i)
        }
        var sm = M.identity
        repeat {
            while left % 2 == 0 { left >>= 1 }
            if !function(M.operate(sm, vertices[left])) {
                while left < treeSize {
                    push(left)
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
        } while (left & -left) != left
        return vertexCount
    }
    
    mutating func minLeft(_ right: Int, _ function: (M.SetType) -> Bool) -> Int {
        assert(0 <= right && right <= vertexCount)
        assert(function(M.identity))
        if right == 0 { return 0 }
        var right = right + treeSize
        for i in (1 ... depth).reversed() {
            push((right - 1) >> i)
        }
        var sm = M.identity
        repeat {
            right -= 1
            while right > 1 && right % 2 != 0 { right >>= 1 }
            if !function(M.operate(vertices[right], sm)) {
                while right < treeSize {
                    push(right)
                    right = 2 * right + 1
                    if function(M.operate(vertices[right], sm)) {
                        sm = M.operate(vertices[right], sm)
                        right -= 1
                    }
                }
                return right + 1 - treeSize
            }
            sm = M.operate(vertices[right], sm)
        } while (right & -right) != right
        return 0
    }
}
