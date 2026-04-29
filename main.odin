package main

main :: proc() {
    graph := graph_init(10, 70)
    defer graph_delete(&graph)

    graph_print(&graph)
}
