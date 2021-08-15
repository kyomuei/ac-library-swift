
struct MaxFlowGraph {    
    
    private struct _Edge {
        var target: Int
        var reverse: Int
        var capacity: Int
    }
    
    struct Edge {
        var pair: (source: Int, target: Int)
        var flow: (rate: Int, capacity: Int)
    }
    
    private var count: Int
    private var position: [(Int, Int)]
    private var graph: [[_Edge]]
    
    func edges() -> [Edge] {
        position.indices.map { getEdge($0) }
    }
    
    func getEdge(_ index: Int) -> Edge {
        assert(position.indices.contains(index))
        let edge = graph[position[index].0][position[index].1]
        let redge = graph[edge.target][edge.reverse]
        return Edge(pair: (position[index].0, edge.target),
                    flow: (redge.capacity, edge.capacity + redge.capacity))
    }
    
    mutating func updateEdge(_ index: Int, newFlow: (rate: Int, capacity: Int)) {
        assert(position.indices.contains(index))
        assert(0 <= newFlow.rate && newFlow.rate <= newFlow.capacity)
        let pos = position[index]
        let edge = graph[pos.0][pos.1]
        graph[edge.target][edge.reverse].capacity = newFlow.rate
        graph[pos.0][pos.1].capacity = newFlow.capacity - newFlow.rate
    }
    
    mutating func flow(from source: Int, to target: Int) -> Int {
        flow(from: source, to: target, limit: Int.max)
    }
    
    mutating func flow(from source: Int, to target: Int, limit: Int) -> Int {
        assert(0 <= source && source < count)
        assert(0 <= target && target < count)
        assert(source != target)

        var level = [Int](repeating: 0, count: count)
        var iter = [Int](repeating: 0, count: count)
        var queue = Internal.Queue<Int>()
        
        func bfs() {
            level.withUnsafeMutableBufferPointer { $0.assign(repeating: -1) }
            level[source] = 0
            queue.clear()
            queue.enqueue(source)
            while !queue.isEmpty {
                let v = queue.dequeue()!
                for edge in graph[v] {
                    if edge.capacity == 0 || level[edge.target] >= 0 {
                        continue
                    }
                    level[edge.target] = level[v] + 1
                    if edge.target == target { return }
                    queue.enqueue(edge.target)
                }
            }
        }
        
        func dfs(_ v: Int, _ upper: Int) -> Int {
            if v == source { return upper }
            var result = 0
            let levelv = level[v]
            while iter[v] < graph[v].count {
                defer { iter[v] += 1 }
                let i = iter[v]
                let edge = graph[v][i]
                if levelv <= level[edge.target] ||
                    graph[edge.target][edge.reverse].capacity == 0 {
                    continue
                }
                let d = dfs(edge.target,
                            min(upper - result, graph[edge.target][edge.reverse].capacity))
                if d <= 0 { continue }
                graph[v][i].capacity += d
                graph[edge.target][edge.reverse].capacity -= d
                result += d
                if result == upper { return result }
            }
            level[v] = count
            return result
        }
        var flow = 0
        while flow < limit {
            bfs()
            if level[target] == -1 { break }
            iter.withUnsafeMutableBufferPointer { $0.assign(repeating: 0) }
            let f = dfs(target, limit - flow)
            flow += f
        }
        return flow
    }
    
    func minCut(_ source: Int) -> [Bool] {
        var visited = [Bool](repeating: false, count: count)
        var queue = Internal.Queue<Int>()
        queue.enqueue(source)
        while !queue.isEmpty {
            let p = queue.dequeue()!
            visited[p] = true
            for edge in graph[p] {
                if edge.capacity != 0 && !visited[edge.target] {
                    visited[edge.target] = true
                    queue.enqueue(edge.target)
                }
            }
        }
        return visited
    }
}
