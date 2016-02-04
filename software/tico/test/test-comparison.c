#include "parser.h"
#include <stdio.h>

unsigned int get_result(unsigned int vector);

int main(int argc, char *argv[]) {

	printf("Parsing input file %s...\n", argv[1]);
	tst_info_t test_info = parse_test_file(argv[1]);
	printf("Successfully parsed.\n");

	printf("config_value: 0x%08X\n", get_config_value(test_info));

	printf("Started testing circuit %s.\n", test_info.circuit_name);

	print_io_signals(test_info);

	printf("Sending test vectors...\n");

	int j, ok_count = 0;
	for (j = 0; j < test_info.vector_cnt; j++) {
		printf("---Vector %d...\n", j + 1);
		unsigned int vector = get_input_vector(test_info.vectors[j]);
		print_vector(test_info.vectors[j]);
		unsigned int result = get_result(vector);
		ok_count += compare_vector_result(test_info.vectors[j],
			result, 0);
	}

	printf("Finished testing %s: %d out of %d test vectors were correct.\n",
		test_info.circuit_name, ok_count, test_info.vector_cnt);

	return 0;
}

/* mockup functino for bcd-decoder-w5 */
unsigned int get_result(unsigned int vector) {
	switch (vector) {
		case 0x00000000: return 0x10000BC;
		case 0x00000002: return 0x00018;
		case 0x00000001: return 0x20000AC;
		case 0x00000003: return 0x200003C;
		case 0x80000000: return 0x3000018;
		case 0x80000002: return 0x3000034;
		case 0x80000001: return 0x30000B4;
		case 0x80000003: return 0x0001C;
		case 0x20000000: return 0x30000BC;
		case 0x20000002: return 0x300003C;
		default: return 0;
	}
}