
/// A Linear-Time Algorithm for Testing the Truth of Certain Quantified Boolean
/// Formulas
/// # Reference
/// B. Aspvall, M. Plass, and R. Tarjan,
struct TwoSAT {
    private var count: Int
    private(set) var answer: [Bool]
    private var scc: Internal.SCCGraph
    
    init(_ n: Int) {
        count = n
        answer = [Bool](repeating: false, count: n)
        scc = Internal.SCCGraph(vertexCount: 2 * n)
    }
    
    mutating func addClause(_ x: (id: Int, value: Bool), _ y: (id: Int, value: Bool)) {
        assert(0 <= x.id && x.id < count)
        assert(0 <= y.id && y.id < count)
        scc.addEdge(from: 2 * x.id + (x.value ? 0 : 1),
                    to: 2 * y.id + (y.value ? 1 : 0))
        scc.addEdge(from: 2 * y.id + (y.value ? 0 : 1),
                    to: 2 * x.id + (x.value ? 1 : 0))
    }
    
    mutating func satisfiable() -> Bool {
        let id = scc.sccIDs().1
        for i in 0 ..< count {
            if id[2 * i] == id[2 * i + 1] { return false }
            answer[i] = id[2 * i] < id[2 * i + 1]
        }
        return true
    }
}
