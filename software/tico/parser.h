#ifndef PARSER_H
#define PARSER_H

#include "jsmn.h"

/* STRUCT DECLARATIONS */

/* Describes a group of input or output pins of the cicuit. */
typedef struct {
	int size; // in bits
	int *pins;
	char *name;
} dut_signal_t;

/* Contains the value to be applied (if input) or expected (if output) for
a signal for a given test vector */
typedef struct {
	unsigned int value;
	dut_signal_t *pin;
} tst_val_t;

/* Contains the values (to be applied or expected) for all signals for a single
vector application to the circuit. Not all output signals are necessarily
present (the ones which are not are considered don't care), but all input
signals must be present. */
typedef struct {
	int input_count;
	int output_count;
	tst_val_t *inputs;
	tst_val_t *outputs;
} tst_vector_t;

/* Contains all information about a test session parsed from a JSON
input file. */
typedef struct {
	char *circuit_name;
	int freq_divider;
	int in_cnt, out_cnt, vector_cnt;
	dut_signal_t *inputs, *outputs;
	tst_vector_t *vectors;
} tst_info_t;

/* FUNCTION DECLARATIONS */

/* Parses the JSON input present in file_buffer and returns a tst_info_t struct
with the parsed info. */
tst_info_t parse_test_file(char *file_buffer);

/* Returns the value to be written to the IP's configuration register. Each bit
represents if the corresponding pin is an input (0) or an output (1).
Unconnected pins are set to outputs and their values won't be compared. */
unsigned int get_config_value(tst_info_t test_info);

/* Returns the input value to be sent to the circuit for a provided vector. */
unsigned int get_input_vector(tst_vector_t vector);

/* Compares the result provided by the circuit for a given vector to the
expected response. Returns 1 if equal, 0 if different. */
int compare_vector_result(tst_vector_t vector, unsigned int result, int silent);

void print_vector(tst_vector_t vector);

void print_io_signals(tst_info_t test_info);

#endif /* PARSER_H */
