package main

import "core:log"
import "core:testing"
import "core:math/rand"
import "core:strings"
import "core:fmt"

MAX_NODE :: 1_000 + 1
ITERATION :: 10_000
SATURATIONS :: [2]u32{30, 70}

@(test)
hamiltononian_graph :: proc(t: ^testing.T) {
    for i in 0..<ITERATION {
        for s in SATURATIONS {
            n := rand.uint32_range(10, MAX_NODE)
            
            graph := graph_init(n, s)

            if !all_edges_even(&graph) {
                log.infof("Failed to create even edges for %d%", s)
                log.info(graph)
                testing.fail(t)
            }

            if has_duplicates(&graph){
                log.infof("Failed to create even edges without duplicates for %d%", s)
                log.info(graph)
                testing.fail(t)
            }

            graph_delete(&graph)
        }
    }
}

@(test)
nonhamiltononian_graph :: proc(t: ^testing.T) {
    // for i in 0..<ITERATION {
        
    //     n := rand.uint32_range(10, MAX_NODE)
        
    //     graph := graph_init(n, 50)

    //     if !all_edges_even(&graph) {
    //         log.infof("Failed to create even edges for %d%", s)
    //         log.info(graph)
    //         testing.fail(t)
    //     }

    //     if has_duplicates(&graph){
    //         log.infof("Failed to create even edges without duplicates for %d%", s)
    //         log.info(graph)
    //         testing.fail(t)
    //     }

    //     graph_delete(&graph)
    // }
}

// zero_init leaking memory and set_edge also
@(test)
euler_cycle :: proc(t: ^testing.T) {
	data, err1 := os.read_entire_file("tests/euler_test.txt", context.allocator)
	if err1 != nil {
		log.info("Couldn't open test file for euler's cycle")
		testing.fail_now(t)
	}
	defer delete(data, context.allocator)

	results, err2 := os.read_entire_file("tests/euler_test.txt", context.allocator)
	if err2 != nil {
		log.info("Couldn't open result file for euler's cycle")
		testing.fail_now(t)
	}
	defer delete(results, context.allocator)

	it_data := string(data)
	it_res := string(results)

	// Fetch how many tests
	str, ok := strings.split_lines_iterator(&it_data)
	tests := strconv.parse_uint(str) or_else 0
	for i in 0 ..< tests {
		graph: Graph

		i: u32 = 0
		edges: u32 = 0
		is_init := false
		for line in strings.split_lines_iterator(&it_data) {
			if i > edges do break
			i += 1

			parts := strings.split(line, " ")
			a := strconv.parse_uint(parts[0]) or_else 0
			b := strconv.parse_uint(parts[1]) or_else 0

			if !is_init {
				graph = graph_zero_init(cast(u32)a)
				edges = cast(u32)b
				is_init = true
				continue
			}

			graph_set_edge(cast(u32)a, cast(u32)b, &graph)
			graph_set_edge(cast(u32)b, cast(u32)a, &graph)
			delete(parts)
		}

		graph_print(&graph)

		path := euler_cycle_path(&graph)
		log.info(path)

		
		
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
