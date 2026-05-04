package main

import "core:fmt"

main :: proc() {
	graph := graph_zero_init(6) // nodes 0-5
	defer graph_delete(&graph)

	// 0 -- 1
	graph_set_edge(0, 1, &graph)
	graph_set_edge(1, 0, &graph)

	// 0 -- 3
	graph_set_edge(0, 3, &graph)
	graph_set_edge(3, 0, &graph)

	// 1 -- 2
	graph_set_edge(1, 2, &graph)
	graph_set_edge(2, 1, &graph)

	// 1 -- 3
	graph_set_edge(1, 3, &graph)
	graph_set_edge(3, 1, &graph)

	// 1 -- 4
	graph_set_edge(1, 4, &graph)
	graph_set_edge(4, 1, &graph)

	// 2 -- 3
	graph_set_edge(2, 3, &graph)
	graph_set_edge(3, 2, &graph)

	// 3 -- 5
	graph_set_edge(3, 5, &graph)
	graph_set_edge(5, 3, &graph)

	// 4 -- 5
	graph_set_edge(4, 5, &graph)
	graph_set_edge(5, 4, &graph)

	euler_path := euler_cycle_path(&graph)
	defer delete(euler_path)

	fmt.println(euler_path)
}
