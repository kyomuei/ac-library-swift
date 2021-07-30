extension Internal {
    struct CSR<Element> {
        var start: [Int]
        var elements: [Element]

        init(edges: [(Int, Element)], count: Int) {
            start = [Int](repeating: 0, count: count + 1)
            elements = [Element](unsafeUninitializedCapacity: edges.count) { 
                $1 = edges.count 
            }
            for edge in edges { start[edge.0 + 1] += 1 }
            for i in 0 ..< count { start[i + 1] += start[i] }
            var counter = start
            for edge in edges {
                counter[edge.0] += 1
                elements[counter[edge.0]] = edge.1
            }
        }
    }
}
