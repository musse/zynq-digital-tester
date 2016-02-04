#ifndef IP_H
#define IP_H

/* CONSTANT DEFINITIONS */

#define DUT_INTERFACE_BURST_CONFIG_S01_AXI_SLV_REG0_OFFSET 0
#define DUT_INTERFACE_BURST_CONFIG_S01_AXI_SLV_REG1_OFFSET 4
#define DUT_INTERFACE_BURST_CONFIG_S01_AXI_SLV_REG2_OFFSET 8
#define DUT_INTERFACE_BURST_CONFIG_S01_AXI_SLV_REG3_OFFSET 12

#define STATUS_REG_OFFSET DUT_INTERFACE_BURST_CONFIG_S01_AXI_SLV_REG0_OFFSET
#define FINISHED_REG_OFFSET DUT_INTERFACE_BURST_CONFIG_S01_AXI_SLV_REG1_OFFSET
#define DUT_CONTROL_OFFSET DUT_INTERFACE_BURST_CONFIG_S01_AXI_SLV_REG2_OFFSET
#define BURST_SIZE_OFFSET DUT_INTERFACE_BURST_CONFIG_S01_AXI_SLV_REG3_OFFSET

#define START_STATUS 1
#define END_STATUS 0

#define IP_MEM_SIZE 1024

extern void *ip_reg_ptr;
extern void *ip_mem_ptr;

/* FUNCTION DECLARATIONS */

/* Maps the IP's UIO device to memory. */
void init_ip_ptrs();

/* Writes the provided value to the given offset of the given base address. */
void ip_write(void *base_ptr, unsigned int offset, unsigned int value);

/* Returns the value of the present in the given offset of the given base
address. */
unsigned int ip_read(void *base_ptr, unsigned int offset);

/* Unmaps IP's device from memory. */
void free_ip_ptrs();

#endif /* IP_H */
