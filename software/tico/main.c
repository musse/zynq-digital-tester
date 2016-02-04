/* tICo : Tester for Integrated Circuits Operation */

#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <unistd.h>
#include <string.h>
#include <time.h>

#include "parser.h"
#include "ip.h"

#define VECTOR_SIZE (sizeof(unsigned int))
#define MAX_VECTORS_PER_ROUND (IP_MEM_SIZE / VECTOR_SIZE)

#define PRINT(arg) do { \
	if (!silent) { \
		printf(arg); \
	} \
} while (0)

static unsigned int send_vector(unsigned int test_value, void *ip_ptr);

static void test_file(char *filepath, int silent, int measure_time);

int main(int argc, char *argv[]) {

	int i, c;
	int silent = 0;
	int measure_time = 0;

	while ((c = getopt(argc, argv, "st")) != -1) {
		switch(c) {
			case 's':
				silent = 1;
				break;
			case 't':
				measure_time = 1;
				break;
			case '?':
				if (isprint (optopt))
					printf("Unknown option `-%c'.\n",
						optopt);
				else
					printf("Unknown option character "
						"'\\x%x'.\n", optopt);
				exit(1);
			default:
				printf("Problem parsing program options.\n");
				exit(1);
		}
	}

	init_ip_ptrs();

	/* test each of the input files */
	for (i = optind; i < argc; i++)
		test_file(argv[i], silent, measure_time);

	return 0;
}

void test_file(char *filepath, int silent, int measure_time) {

	clock_t begin, end;
	double time_parse, time_test;

	printf("Parsing input file %s...\n", filepath);

	if (measure_time)
		begin = clock();

	tst_info_t test_info = parse_test_file(filepath);

	if (measure_time) {
		end = clock();
		time_parse = (double)(end - begin) / CLOCKS_PER_SEC;
	}

	printf("Successfully parsed.\n");

	printf("Started testing circuit %s.\n", test_info.circuit_name);

	if (!silent)
		print_io_signals(test_info);

	if (measure_time)
		begin = clock();

	/* configures circuit pins in IP */
	ip_write(ip_reg_ptr, DUT_CONTROL_OFFSET, get_config_value(test_info));

	printf("Sending test vectors...\n");

	unsigned int round_vectors[MAX_VECTORS_PER_ROUND];
	int current_round = 0;
	int ok_count = 0;
	int remaining_vector_cnt = test_info.vector_cnt;

	while (remaining_vector_cnt > 0) {

		int current_vector_cnt;
		if (remaining_vector_cnt >= MAX_VECTORS_PER_ROUND)
			current_vector_cnt = MAX_VECTORS_PER_ROUND;
		else
			current_vector_cnt = remaining_vector_cnt;

		int j;
		for (j = 0; j < current_vector_cnt; j++)
			round_vectors[j] = get_input_vector(test_info.vectors[
				current_round * MAX_VECTORS_PER_ROUND + j]);

		memcpy(ip_mem_ptr, (void*)round_vectors, current_vector_cnt *
			VECTOR_SIZE);

		ip_write(ip_reg_ptr, BURST_SIZE_OFFSET, current_vector_cnt);
		ip_write(ip_reg_ptr, STATUS_REG_OFFSET, START_STATUS);

		while ((ip_read(ip_reg_ptr, FINISHED_REG_OFFSET) & 0x1) == 0) {
			/* nothing: waits for end of tests */
		}
		memcpy((void*)round_vectors, ip_mem_ptr, current_vector_cnt *
			VECTOR_SIZE);

		ip_write(ip_reg_ptr, STATUS_REG_OFFSET, END_STATUS);

		for (j = 0; j < current_vector_cnt; j++) {
			unsigned int vector_idx = current_round *
				MAX_VECTORS_PER_ROUND + j;

			if (!silent)
				printf("---Vector %d...\n", vector_idx + 1);

			tst_vector_t current_vector = test_info.vectors[
				vector_idx];

			if (!silent)
				print_vector(current_vector);

			unsigned int result = round_vectors[j];

			ok_count += compare_vector_result(current_vector,
				result, silent);
		}

		remaining_vector_cnt -= current_vector_cnt;
		current_round++;
	}

	if (measure_time) {
		end = clock();
		time_test = (double)(end - begin) / CLOCKS_PER_SEC;
	}

	printf("Finished testing %s: %d out of %d test vectors were correct.\n",
		test_info.circuit_name, ok_count, test_info.vector_cnt);

	if (measure_time) {
		printf("Time spent parsing: %f seconds.\n", time_parse);
		printf("Time spent testing: %f seconds.\n", time_test);
	}

	free_ip_ptrs();
}
