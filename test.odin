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

@(private="file")
all_edges_even :: proc(graph: ^Graph) -> bool {
    for key, val in graph.lists {
        if(len(val^) % 2 != 0) do return false
    }

    return true
}


@(private="file")
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
