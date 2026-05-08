package main

import "core:fmt"
import "core:log"
import "core:math/rand"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:testing"

GEN_MAX_NODE :: 100
PATH_MAX_NODE :: 15
ITERATION :: 10_000
SATURATIONS :: [2]u32{30, 70}

@(test)
hamiltononian_graph :: proc(t: ^testing.T) {
	for i in 0 ..< ITERATION {
		for s in SATURATIONS {
			n := rand.uint32_range(10, GEN_MAX_NODE)

			graph := graph_init(n, s)

			if !all_edges_even(&graph) {
				log.infof("Failed to create even edges for %d%", s)
				log.info(graph)
				testing.fail_now(t)
			}

			if has_duplicates(&graph) {
				log.infof("Failed to create even edges without duplicates for %d%", s)
				log.info(graph)
				testing.fail_now(t)
			}

			graph_delete(&graph)
		}
	}
}

//@(test)
nonhamiltononian_graph :: proc(t: ^testing.T) {
	for i in 0 ..< ITERATION {
		n := rand.uint32_range(10, GEN_MAX_NODE)

		graph := graph_init(n, 50, false)

		if !all_edges_even(&graph) {
			log.info("Failed to create nonhamiltonian graph (uneven edges)")
			log.info(graph)
			testing.fail_now(t)
		}

		if has_duplicates(&graph) {
			log.info("Failed to create nonhamiltonian graph (contains duplicates)")
			log.info(graph)
			testing.fail_now(t)
		}

		graph_delete(&graph)
	}
}

@(test)
euler_cycle_test :: proc(t: ^testing.T) {
	for i in 0 ..< ITERATION {
		for s in SATURATIONS {
			n := rand.uint32_range(10, PATH_MAX_NODE)

			graph := graph_init(n, s)

			path := euler_cycle_path(&graph)

			if path == nil {
				log.info("The path from generated euler cycle doesn't exist: %v", path[:])
				testing.fail(t)
			}

			delete(path)
			graph_delete(&graph)
		}
	}
}

@(test)
ham_cycle_gen :: proc(t: ^testing.T) {
	for i in 0 ..< ITERATION {
		for s in SATURATIONS {
			n := rand.uint32_range(10, PATH_MAX_NODE)

			graph := graph_init(n, s)

			path := ham_cycle_path(&graph)

			if path == nil {
				log.info("The path from generated hamilton cycle doesn't exist: %v", path[:])
				testing.fail(t)
			}

			delete(path)
			graph_delete(&graph)
		}
	}
}

@(test)
nonham_cycle_gen :: proc(t: ^testing.T) {
	//for i in 0 ..< ITERATION {
	n: u32 = 7

	graph := graph_init(n, 50, false)
	log.info(graph.lists)
	path := ham_cycle_path(&graph)

	if path == nil {
		log.info("The path from generated hamilton cycle does exist: %v", path[:])
		testing.fail(t)
	}

	delete(path)
	graph_delete(&graph)
	//}
}

//@(test)
euler_cycle_file :: proc(t: ^testing.T) {
	data, err1 := os.read_entire_file("tests/euler_test.txt", context.allocator)
	if err1 != nil {
		log.info("Couldn't open test file for euler's cycle")
		testing.fail_now(t)
	}
	defer delete(data, context.allocator)

	results, err2 := os.read_entire_file("tests/euler_solution.txt", context.allocator)
	if err2 != nil {
		log.info("Couldn't open result file for euler's cycle")
		testing.fail_now(t)
	}
	defer delete(results, context.allocator)

	it_data := string(data)
	it_res := string(results)

	// Fetch how many tests
	str, _ := strings.split_lines_iterator(&it_data)
	tests := strconv.parse_uint(str) or_else 0
	for i in 0 ..< tests {
		init_vals, _ := strings.split_lines_iterator(&it_data)
		vals := strings.split(init_vals, " ")
		nodes := strconv.parse_uint(vals[0]) or_else 0
		edges := strconv.parse_uint(vals[1]) or_else 0
		delete(vals)

		graph := graph_zero_init(cast(u32)nodes)

		for line in strings.split_lines_iterator(&it_data) {
			if line == "" do break

			parts := strings.split(line, " ")
			n1 := strconv.parse_uint(parts[0]) or_else 0
			n2 := strconv.parse_uint(parts[1]) or_else 0

			graph_set_edge(cast(u32)n1, cast(u32)n2, &graph)
			graph_set_edge(cast(u32)n2, cast(u32)n1, &graph)
			delete(parts)
		}

		expected, _ := strings.split_lines_iterator(&it_res)
		path := euler_cycle_path(&graph)
		if !is_result_correct(&path, &expected) {
			log.infof(
				"Result of Euler cycle (file) is incorrect, expected: %s, got: %v",
				expected,
				path,
			)
			testing.fail(t)
		}

		delete(path)
		graph_delete(&graph)
	}
}

@(private = "file")
all_edges_even :: proc(graph: ^Graph) -> bool {
	for key, val in graph.lists {
		if (len(val^) % 2 != 0) do return false
	}

	return true
}

@(private = "file")
has_duplicates :: proc(graph: ^Graph) -> bool {
	for key, arr in graph.lists {
		seen := make(map[u32]bool)
		for v in arr^ {
			if seen[v] do return true
			seen[v] = true
		}
		delete(seen)
	}

	return false
}

@(private = "file")
is_result_correct :: proc(res: ^[dynamic]u32, str: ^string) -> bool {
	nums_str := strings.split(str^, " ")
	defer delete(nums_str)

	if len(nums_str) + 1 != len(res^) do return false

	// Because the starting node doesn't matter in a cycle
	// we chech from which point the result starts and then we loop
	// through string accordingly
	mods := make([dynamic]u32)
	defer delete(mods)

	start := res[0]
	for num_str, idx in nums_str {
		num, _ := strconv.parse_uint(num_str)
		if cast(u32)num == res[0] {
			append_elem(&mods, cast(u32)(idx))
		}
	}

	for mod in mods {
		correct := true
		for j in 0 ..< len(res) {
			rotated_idx := (cast(u32)j + mod) % cast(u32)len(nums_str)
			num, _ := strconv.parse_uint(nums_str[rotated_idx])
			if cast(u32)num != res[j] {
				correct = false
				break
			}
		}
		if correct do return true
	}
	return false
}
