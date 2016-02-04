#include "jsmn.h"
#include "parser.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

// #define PARSER_DEBUG

#define CHECK_CALLOC(ptr) do { \
	if ((ptr) == NULL) { \
		printf("Problem allocating memory.\n"); \
		exit(1); \
	} \
} while (0)

#define POW2(power) (1 << (power))

/* INTERNAL FUNCTIONS PROTOTYPES */

static char *str_from_token(jsmntok_t token, char *file_buffer);

static int cmp_str_to_token(char *str, jsmntok_t token, char *file_buffer);

static dut_signal_t *get_ios_from_object(int *current_token, jsmntok_t *tokens,
		char *file_buffer);

static tst_vector_t get_tst_vector_from_object(int *current_token,
		jsmntok_t *tokens, char *file_buffer, dut_signal_t *inputs,
		int in_pin_cnt, dut_signal_t *outputs, int out_pin_cnt);

static tst_val_t *get_vector_io_values(int val_cnt, dut_signal_t *pins,
	int pin_cnt, int *current_token, jsmntok_t *tokens, char *file_buffer);

static char *get_file_buffer(char *filepath);

static void check_repeated_pins(tst_info_t test_info);

static void print_tokens(jsmntok_t *tokens, int token_cnt, char *file_buffer);

/* FUNCTION DEFINITIONS */

char *str_from_token(jsmntok_t token, char* file_buffer) {
	unsigned int length = token.end - token.start;
	char* str = (char*)calloc(length + 1, sizeof(char));
	CHECK_CALLOC(str);

	memcpy(str, &file_buffer[token.start], length);
	str[length] = '\0';
	return str;
}

int cmp_str_to_token(char *str, jsmntok_t token, char *file_buffer) {
	unsigned int length = token.end - token.start;
	return strncmp(str, &file_buffer[token.start], length);
}

dut_signal_t *get_ios_from_object(int *current_token, jsmntok_t *tokens,
		char *file_buffer) {

	int j, k, l, m;

	int io_count = tokens[*current_token].size;
	(*current_token)++;
	dut_signal_t *ios =
		(dut_signal_t*)calloc(io_count, sizeof(dut_signal_t));
	CHECK_CALLOC(ios);

	for (j = 0; j < io_count; j++) {
		ios[j].name = str_from_token(tokens[*current_token],
				file_buffer);
		for (k = 0; k < j; k++) {
			if (!strcmp(ios[j].name, ios[k].name)) {
				printf("Repeated IO pin name: %s.\n",
					ios[j].name);
				exit(1);
			}
		}

		(*current_token)++;

		if (tokens[*current_token].type == JSMN_ARRAY) {
			ios[j].size = tokens[*current_token].size;
			(*current_token)++;
		} else {
			ios[j].size = 1;
		}

		ios[j].pins = (int*)calloc(ios[j].size, sizeof(int));
		CHECK_CALLOC(ios[j].pins);

		/* from MSB to LSB */
		for (k = ios[j].size - 1; k >= 0; k--) {
			ios[j].pins[k] = int_from_token(
				tokens[*current_token], file_buffer);

			if (ios[j].pins[k] > 32 || ios[j].pins[k] <= 0) {
				printf("Invalid pin number (%d) for %s.\n",
					ios[j].pins[k], ios[j].name);
				exit(1);
			}

			(*current_token)++;
		}

		/* checking for repeated pins */
		for (k = 0; k < ios[j].size; k++) {
			for (l = 0; l < j; l++) {
				for (m = 0; m < ios[l].size; m++) {
					if (ios[j].pins[k] == ios[l].pins[m]) {
						printf("Repeated IO pin: %d.\n",
							ios[j].pins[k]);
						exit(1);
					}
				}
			}
		}
		for (k = 0; k < ios[j].size; k++) {
			for (l = k + 1; l < ios[j].size; l++) {
				if (ios[j].pins[k] == ios[j].pins[l]) {
					printf("Repeated IO pin: %d.\n",
						ios[j].pins[k]);
					exit(1);
				}
			}
		}

	}
	return ios;
}

tst_vector_t get_tst_vector_from_object(int *current_token, jsmntok_t *tokens,
	char *file_buffer, dut_signal_t *inputs, int in_pin_cnt,
	dut_signal_t *outputs, int out_pin_cnt) {

	tst_vector_t vector;

	assert(tokens[*current_token].type == JSMN_OBJECT);
	assert(tokens[*current_token].size == 2);
	(*current_token)++;

	assert(tokens[*current_token].type == JSMN_STRING);
	assert(tokens[*current_token].size == 1);
	assert(!cmp_str_to_token("in", tokens[*current_token], file_buffer));
	(*current_token)++;

	vector.input_count = tokens[*current_token].size;
	if (vector.input_count < in_pin_cnt) {
		printf("All inputs must be set for all vectors.\n");
		exit(1);
	}

	(*current_token)++;

	vector.inputs = get_vector_io_values(vector.input_count, inputs,
		in_pin_cnt, current_token, tokens, file_buffer);

	assert(tokens[*current_token].type == JSMN_STRING);
	assert(tokens[*current_token].size == 1);
	assert(!cmp_str_to_token("out", tokens[*current_token], file_buffer));
	(*current_token)++;

	vector.output_count = tokens[*current_token].size;
	(*current_token)++;

	vector.outputs = get_vector_io_values(vector.output_count, outputs,
		out_pin_cnt, current_token, tokens, file_buffer);

	return vector;

}

tst_val_t *get_vector_io_values(int val_cnt, dut_signal_t *pins, int pin_cnt,
	int *current_token, jsmntok_t *tokens, char *file_buffer) {

	tst_val_t *values = (tst_val_t*)calloc(val_cnt, sizeof(tst_val_t));
	CHECK_CALLOC(values);

	int i;
	for (i = 0; i < val_cnt; i++) {
		assert(tokens[*current_token].type == JSMN_STRING);

		int j;
		for (j = 0; j < pin_cnt; j++) {
			if (!cmp_str_to_token(pins[j].name,
				tokens[*current_token], file_buffer)) {
				values[i].pin = &(pins[j]);
				break;
			}
		}

		/* if the for was finished without a call to break, the pin
		name was not found in the IO pins */
		if (j == pin_cnt) {
			printf("Problem: IO pin %s is undeclared.\n",
				str_from_token(tokens[*current_token],
					file_buffer));
			exit(1);
		}

		/* checking for repeated pin names in this vector */
		for (j = i - 1; j >= 0; j--) {
			if (!strcmp(values[i].pin->name, values[j].pin->name)) {
				printf("Repeated pin name %s in vector.\n",
					values[i].pin->name);
				exit(1);
			}
		}

		(*current_token)++;

		values[i].value = int_from_token(tokens[*current_token],
			file_buffer);

		if (values[i].value > (POW2(values[i].pin->size) - 1)) {
			printf("Invalid value for pin %s, %d bits can't hold "
				"value %d.\n", values[i].pin->name,
				values[i].pin->size, values[i].value);
			exit(1);
		}

		(*current_token)++;
	}
	return values;
}

int int_from_token(jsmntok_t token, char *file_buffer) {
	assert(token.type == JSMN_PRIMITIVE);
	char *str = str_from_token(token, file_buffer);
	int value = strtol(str, NULL, 0); /* auto-detects base to allow hex */
	free(str);
	return value;
}

unsigned int get_config_value(tst_info_t test_info) {
	unsigned int config_value = ~0;
	int i;
	for (i = 0; i < test_info.in_cnt; i++) {
		int j;
		for (j = 0; j < test_info.inputs[i].size; j++) {
			config_value &= ~(1 << (test_info.inputs[i].
				pins[j] - 1));
		}
	}
	return config_value;
}

unsigned int get_input_vector(tst_vector_t vector) {
	unsigned int input_vector = 0;
	int i;
	for (i = 0; i < vector.input_count; i++) {
		tst_val_t input_value = vector.inputs[i];
		int value = input_value.value;
		int j;
		for (j = 0; j < input_value.pin->size; j++) {
			input_vector |= (((value & (1 << j)) >> j)
				<< (input_value.pin->pins[j] - 1));
		}
	}
	return input_vector;
}

int compare_vector_result(tst_vector_t vector, unsigned int result,
		int silent) {

	int ok = 1;
	int i;
	for (i = 0; i < vector.output_count; i++) {
		tst_val_t out_val = vector.outputs[i];
		int expected_val = out_val.value;
		int j, received_val = 0;
		for (j = 0; j < out_val.pin->size; j++) {
			received_val |= (((result & (1 <<
				(out_val.pin->pins[j] - 1))) >>
				(out_val.pin->pins[j] - 1)) << j);
		}
		if (expected_val != received_val) {
			ok = 0;
			if (!silent)
				printf("------Error for signal %s: expected "
					"0x%X, received 0x%X.\n", out_val.pin->
					name, expected_val, received_val);
		}
	}

	if (ok && !silent)
		printf("------OK: all signals as expected.\n");

	return ok;
}

void check_repeated_pins(tst_info_t test_info) {
	int i, j, k, l;
	for (i = 0; i < test_info.in_cnt; i++)
		for (j = 0; j < test_info.inputs[i].size; j++)
			for (k = 0; k < test_info.out_cnt; k++)
				for (l = 0; l < test_info.outputs[k].size; l++)
					if (test_info.inputs[i].pins[j] ==
						test_info.outputs[k].pins[l]) {
						printf("Repeated IO pin: %d.\n",
							test_info.outputs[k].
							pins[l]);
						exit(1);
					}
}

void print_io_signals(tst_info_t test_info) {
	int k, l;
	printf("Input/Output signals:\n");
	printf("---Input signals:\n");
	for (k = 0; k < test_info.in_cnt; k++) {
		printf("------%s: %d bit%c, pins = ", test_info.inputs[k].name,
			test_info.inputs[k].size,
			(test_info.inputs[k].size == 1 ? '\0' : 's'));
		for (l = test_info.inputs[k].size - 1; l >= 0; l--)
			printf("%d ", test_info.inputs[k].pins[l]);
		printf("\n");
	}

	printf("---Output signals:\n");
	for (k = 0; k < test_info.out_cnt; k++) {
		printf("------%s: %d bit%c, pins = ", test_info.outputs[k].name,
			test_info.outputs[k].size,
			(test_info.outputs[k].size == 1 ? '\0' : 's'));
		for (l = test_info.outputs[k].size - 1; l >= 0; l--)
			printf("%d ", test_info.outputs[k].pins[l]);
		printf("\n");
	}
}

void print_vector(tst_vector_t vector) {
	int l;
	printf("------Sent inputs:\n");
	for (l = 0; l < vector.input_count; l++) {
		printf("---------%s: 0x%X\n", vector.inputs[l].pin->name,
			vector.inputs[l].value);
	}
	printf("------Expected outputs:\n");
	for (l = 0; l < vector.output_count; l++) {
		printf("---------%s: 0x%X\n", vector.outputs[l].pin->name,
			vector.outputs[l].value);
	}
}

void print_tokens(jsmntok_t *tokens, int token_cnt, char *file_buffer) {
	int k;
	printf("Token count: %d\n", token_cnt);
	for (k = 0; k < token_cnt; k++) {
		printf("token[%d] = type %d, size = %d, info: %s\n", k,
			tokens[k].type, tokens[k].size,
			str_from_token(tokens[k], file_buffer));
	}
}

tst_info_t parse_test_file(char *filepath) {
	char *file_buffer = get_file_buffer(filepath);

	jsmn_parser parser;
	jsmn_init(&parser);

	/* getting required token count to parse JSON file */
	int token_cnt = jsmn_parse(&parser, file_buffer, strlen(file_buffer),
		NULL, 0);

	jsmntok_t *tokens = (jsmntok_t*)calloc(token_cnt, sizeof(jsmntok_t));
	CHECK_CALLOC(tokens);

	/* parsing JSON file */
	jsmn_init(&parser); // resets parser
	int result = jsmn_parse(&parser, file_buffer, strlen(file_buffer),
		tokens, token_cnt);

	/* handling parser errors */
	if (result < 0) {
		if (result == JSMN_ERROR_INVAL)
			printf("Invalid JSON input file.\n");
		else if (result == JSMN_ERROR_NOMEM)
			printf("Problem allocating enough tokens for provided "
				"JSON file.\n");
		else /* result == JSMN_ERROR_PART */
			printf("JSON is too short, expecting more data.\n");

		exit(1);
	}

#ifdef PARSER_DEBUG
	print_tokens(tokens, token_cnt, file_buffer);
#endif

	tst_info_t test_info;

	int i = 1; /* token index (token 0 is root object) */

	/* we do a 'while' for the unlikely case of the root object's members
	not being in the standard order */
	while (i != token_cnt) {
		if (!cmp_str_to_token("circuit-name", tokens[i], file_buffer)) {
			i++;
			test_info.circuit_name = str_from_token(tokens[i],
				file_buffer);
			i++;
		}

		if (!cmp_str_to_token("freq-divider", tokens[i], file_buffer)) {
			i++;
			test_info.freq_divider = int_from_token(tokens[i],
				file_buffer);
			i++;
		}

		if (!cmp_str_to_token("inputs", tokens[i], file_buffer)) {
			i++;
			test_info.in_cnt = tokens[i].size;
			test_info.inputs = get_ios_from_object(&i, tokens,
				file_buffer);
		}

		if (!cmp_str_to_token("outputs", tokens[i], file_buffer)) {
			i++;
			test_info.out_cnt = tokens[i].size;
			test_info.outputs = get_ios_from_object(&i, tokens,
				file_buffer);
		}

		/* check for repeated pins between output and input */
		check_repeated_pins(test_info);

		if (!cmp_str_to_token("vectors", tokens[i], file_buffer)) {
			i++;
			test_info.vector_cnt = tokens[i].size;
			test_info.vectors = (tst_vector_t*)calloc(test_info.
				vector_cnt, sizeof(tst_vector_t));
			CHECK_CALLOC(test_info.vectors);

			i++;
			int j;
			for (j = 0; j < test_info.vector_cnt; j++) {
				test_info.vectors[j] =
					get_tst_vector_from_object(&i,
					tokens, file_buffer, test_info.inputs,
					test_info.in_cnt, test_info.outputs,
					test_info.out_cnt);
			}
		}
	}
	free(file_buffer);
	return test_info;
}

char *get_file_buffer(char *filepath) {
	FILE *file = fopen(filepath, "r");

	if (file == NULL) {
		printf("Could not open provided input file.\n");
		exit(1);
	}

	/* seek to end of file to get file size and then seek back to
	beggining */
	fseek(file, 0L, SEEK_END);
	unsigned long file_size = ftell(file);
	fseek(file, 0L, SEEK_SET);

	/* allocate enough memory to store whole file */
	char* file_buffer = (char*)calloc(file_size + 1, sizeof(char));

	if (file_buffer == NULL) {
		printf("Could not allocate memory to parse file.\n");
		exit(1);
	}

	/* copy whole file to memory */
	fread(file_buffer, sizeof(char), file_size, file);
	file_buffer[file_size] = '\0';

	fclose(file);

	return file_buffer;
}
