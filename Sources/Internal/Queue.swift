extension Internal {
    struct Queue<Element> {

        private var payload: [Element] = []

        private var position: Int = 0

        var count: Int { payload.count - position }
        
        var isEmpty: Bool { return position == payload.count }

        var front: Element { payload[position] }

        mutating func enqueue(_ newElement: Element) {
            payload.append(newElement)
        }
        
        mutating func dequeue() -> Element? {
            if isEmpty { return nil }
            let x = front
            position += 1
            return x
        }

        mutating func clear() {
            payload.removeAll()
            position = 0
        }
    }
}
