#include "ip.h"

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>

#define REG_MAPPING_OFFSET 0
#define MEM_MAPPING_OFFSET 1

#define IP_MAP_SIZE 0x10000 // 64K

void *ip_reg_ptr;
void *ip_mem_ptr;

void init_ip_ptrs() {
	char *ip_uio_df = "/dev/uio0"; // UIO device file

	int ip_fd = open(ip_uio_df, O_RDWR);

	if (ip_fd == -1) {
		printf("Invalid UIO device file: %s.\n", ip_uio_df);
		exit(1);
	}

	/* mmap the UIO device */
	ip_reg_ptr = mmap(NULL, IP_MAP_SIZE, PROT_READ|PROT_WRITE,
		MAP_SHARED, ip_fd, REG_MAPPING_OFFSET * getpagesize());

	ip_mem_ptr = mmap(NULL, IP_MAP_SIZE, PROT_READ|PROT_WRITE,
		MAP_SHARED, ip_fd, MEM_MAPPING_OFFSET * getpagesize());
}

void free_ip_ptrs() {
	munmap(ip_reg_ptr, IP_MAP_SIZE);
	munmap(ip_mem_ptr, IP_MAP_SIZE);
}

void ip_write(void *base_ptr, unsigned int offset, unsigned int value) {
	*((unsigned *)(base_ptr + offset)) = value;
}

unsigned int ip_read(void *base_ptr, unsigned int offset) {
	return *((unsigned *)(base_ptr + offset));
}
