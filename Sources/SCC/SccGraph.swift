
struct SccGraph {
    private var graph: Internal.SCCGraph
    
    init(vertexCount: Int) {
        graph = Internal.SCCGraph(vertexCount: vertexCount)
    }
    
    mutating func addEdge(from source: Int, to target: Int) {
        let n = graph.vertexCount
        assert(0 <= source && source < n)
        assert(0 <= target && target < n)
        graph.addEdge(from: source, to: target)
    }
    
    func scc() -> [[Int]] {
        return graph.scc()
    }
}
