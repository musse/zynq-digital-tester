#include "parser.h"
#include <stdio.h>

int main(int argc, char *argv[]) {
	if (argc != 2) {
		printf("Invalid argument count, should pass json file to "
			"parse.\n");
	}

	tst_info_t test_info = parse_test_file(argv[1]);
	printf("Successfully parsed.\n");
	printf("config_value: 0x%08X\n", get_config_value(test_info));
	return 0;
}
