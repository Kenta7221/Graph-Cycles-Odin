package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:os"

Graph :: struct {
    lists: map[u32]^[dynamic]u32,
    n : u32,
}

graph_init :: proc(n, s: u32) -> Graph {
    if n < 10 {
        fmt.println("Node amount is too small, n > 10")
        os.exit(1)
    }

    graph := Graph{
        lists = make(map[u32]^[dynamic]u32), 
        n = n
    }

    for i in 0..<n {
        arr := new([dynamic]u32)
        arr^ = make([dynamic]u32)
        graph.lists[i] = arr
    }

    cycle := make([]u32, n)
    defer delete(cycle)

    for i in 0..<n do cycle[i] = i
    rand.shuffle(cycle)

    // Tie loose ends
    graph_set_edge(cycle[0], cycle[n - 1], &graph)
    graph_set_edge(cycle[n - 1], cycle[0], &graph)
    for i in 1..<n {
        graph_set_edge(cycle[i], cycle[i - 1], &graph)
        graph_set_edge(cycle[i - 1], cycle[i], &graph)
    }

    e_max: u32 = cast(u32)(n * (n-1) / 2)
    e_target: u32 = cast(u32)math.ceil(cast(f32)(s) / 100.0 * cast(f32)e_max)
    remaining := e_target - n
    remaining = remaining - (remaining % 3)

    candidates := make([dynamic][2]u32)
    defer delete(candidates)

    for i in 0..<n {
        for j in i+1..<n {
            if !graph_has_edge(i, j, &graph) {
                append_elem(&candidates, [2]u32{i, j})
            }
        }
    }

    rand.shuffle(candidates[:])

    i := 0
    attempts := 0
    edges_added : u32 = 0
    for edges_added < remaining {
        attempts += 1
        if attempts > 10000 do break  // safety exit if graph too dense

        a := candidates[i][0]
        b := candidates[i][1]
        c := rand.uint32_range(0, n)
        
        if b == c || a == c do continue

        if graph_has_edge(a, b, &graph) do continue
        if graph_has_edge(a, c, & graph) do continue
        if graph_has_edge(b, c, & graph) do continue

        graph_set_edge(a, b, &graph)
        graph_set_edge(b, a, &graph)
        graph_set_edge(b, c, &graph)
        graph_set_edge(c, b, &graph)
        graph_set_edge(a, c, &graph)
        graph_set_edge(c, a, &graph)
        edges_added += 3

        i += 1
    }

    return graph
}

graph_delete :: proc(graph: ^Graph) {
    for _, arr in graph.lists {
        delete(arr^)
        free(arr)
    }
    delete(graph.lists)
}

graph_set_edge :: proc(i, j: u32, graph: ^Graph) {
    if i > graph.n || j > graph.n {
        fmt.println("Node is out of bounds")
        os.exit(1)
    }

    arr := graph.lists[i]
    append_elem(arr, j)
}

graph_has_edge :: proc(i, j: u32, graph: ^Graph) -> bool {
    arr := graph.lists[i]
    for v in arr^ do if v == j do return true
    return false
}

graph_print :: proc(graph: ^Graph) {
    for idx, val in graph.lists {
        fmt.printfln("%d: %v", idx, val[:])
    }
}
