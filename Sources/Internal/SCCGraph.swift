extension Internal {
    /// Depth-First Search and Linear Graph Algorithms
    /// # Reference
    /// R. Tarjan
    struct SCCGraph {
        private struct Edge {
            var dest: Int
        }
        let vertexCount: Int
        private var edges: [(Int, Edge)] = []

        init(vertexCount: Int) {
            self.vertexCount = vertexCount
        }

        mutating func addEdge(from start: Int, to end: Int) {
            edges.append((start, Edge(dest: end)))
        }

        func sccIDs() -> (Int, [Int]) {
            let g = CSR<Edge>(edges: edges, count: vertexCount)
            var nowOrd = 0, groupNumber = 0
            var visited: [Int] = []
            var low = [Int](repeating: 0, count: vertexCount)
            var ord = [Int](repeating: -1, count: vertexCount)
            var ids = [Int](repeating: 0, count: vertexCount)

            func dfs(_ v: Int) {
                nowOrd += 1
                low[v] = nowOrd
                ord[v] = nowOrd
                visited.append(v)
                var i = g.start[v]
                while i < g.start[v + 1] { defer { i += 1 } 
                    let dest = g.elements[i].dest
                    if ord[dest] == -1 {
                        dfs(dest)
                        low[v] = min(low[v], low[dest])
                    } else {
                        low[v] = min(low[v], ord[dest])
                    }
                }
                if low[v] == ord[v] {
                    while true {
                        let u = visited.popLast()!
                        ord[u] = vertexCount
                        ids[u] = groupNumber
                        if u == v { break }
                    }
                    groupNumber += 1
                }
            }
            for i in 0 ..< vertexCount {
                if ord[i] == -1 { dfs(i) }
            }
            for i in ids.indices {
                ids[i] = groupNumber - 1 - ids[i]
            }
            return (groupNumber, ids)
        }

        func scc() -> [[Int]] {
            let ids = sccIDs()
            let groupNumber = ids.0
            var counts = [Int](repeating: 0, count: groupNumber)
            for x in ids.1 { counts[x] += 1 }
            var groups = [[Int]](repeating: [], count: groupNumber)
            for i in 0 ..< vertexCount {
                groups[ids.1[i]].append(i)
            }
            return groups
        }
    }
}
