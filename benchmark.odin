package main

import "core:fmt"
import "core:math/rand"
import "core:os"
import "core:strings"
import "core:time"

Benchmark :: enum {
	Ham_Graph,
	NonHam_Graph,
}

TEST_SIZE :: 6

main :: proc() {
	nodes_size := [TEST_SIZE]u32{20, 22, 24, 26, 28, 30}
	graph_time: [TEST_SIZE][3]f64
	stopwatch: time.Stopwatch

	for bench in Benchmark {
		fmt.printf("[%v]\n", bench)
		for n, node_idx in nodes_size {
			fmt.println(bench, n)

			graph: Graph

			#partial switch bench {
			case .Ham_Graph:
				duration: time.Duration

				// Init
				time.stopwatch_reset(&stopwatch)
				time.stopwatch_start(&stopwatch)

				graph = graph_init(n, 30)

				time.stopwatch_stop(&stopwatch)

				duration = time.stopwatch_duration(stopwatch)
				graph_time[node_idx][0] = time.duration_seconds(duration)

				// Euler cycle
				time.stopwatch_reset(&stopwatch)
				time.stopwatch_start(&stopwatch)

				euler := euler_cycle_path(&graph)

				time.stopwatch_stop(&stopwatch)

				duration = time.stopwatch_duration(stopwatch)
				graph_time[node_idx][1] = time.duration_seconds(duration)

				// Hamilton cycle
				time.stopwatch_reset(&stopwatch)
				time.stopwatch_start(&stopwatch)

				ham := ham_cycle_path(&graph)

				time.stopwatch_stop(&stopwatch)

				duration = time.stopwatch_duration(stopwatch)

				graph_time[node_idx][2] = time.duration_seconds(duration)

				delete(euler)
				delete(ham)
			case .NonHam_Graph:
				duration: time.Duration

				// Init
				time.stopwatch_reset(&stopwatch)
				time.stopwatch_start(&stopwatch)

				graph = graph_init(n, 50, false)

				time.stopwatch_stop(&stopwatch)

				duration = time.stopwatch_duration(stopwatch)
				graph_time[node_idx][0] = time.duration_seconds(duration)

				// Hamilton cycle
				time.stopwatch_reset(&stopwatch)
				time.stopwatch_start(&stopwatch)

				ham := euler_cycle_path(&graph)

				time.stopwatch_stop(&stopwatch)

				duration = time.stopwatch_duration(stopwatch)
				graph_time[node_idx][1] = time.duration_seconds(duration)

				delete(ham)
			}
		}

		if bench == .Ham_Graph {
			write_csv(bench, 3, nodes_size, graph_time, {"init", "euler", "hamilton"})
		} else {
			write_csv(bench, 3, nodes_size, graph_time, {"init", "hamilton", "-"})
		}
		fmt.println()
	}
}

@(private = "file")
write_csv :: proc(
	bench: Benchmark,
	n: i32,
	nodes_size: [TEST_SIZE]u32,
	graph_time: [TEST_SIZE][3]f64,
	names: [3]string,
) {
	for op_idx in 0 ..< n {
		sb: strings.Builder
		strings.builder_init(&sb)
		defer strings.builder_destroy(&sb)

		strings.write_string(&sb, "n;sec\n")
		for i in 0 ..< TEST_SIZE {
			strings.write_string(
				&sb,
				fmt.tprintf("%d;%.3f\n", nodes_size[i], graph_time[i][op_idx]),
			)
		}

		filename := fmt.tprintf("bin/%v_%s.csv", bench, names[op_idx])
		filename = strings.to_lower(filename)
		err := os.write_entire_file_from_string(filename, strings.to_string(sb))
		if err != nil {
			fmt.println("Error creating file:", filename)
			os.exit(1)
		}
	}
}
