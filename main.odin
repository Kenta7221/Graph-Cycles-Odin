package main

import "core:fmt"

main :: proc() {
	graph := graph_init(10, 70)
	defer graph_delete(&graph)

	graph_print(&graph)

	path := ham_cycle_path(&graph)
	defer delete(path)

	fmt.println(path)
}
