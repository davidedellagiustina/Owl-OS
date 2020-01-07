// @desc     Memory-related functions header
// @author   Davide Della Giustina
// @date     07/01/2020

#ifndef MEM_H
#define MEM_H

#include "../cpu/types.h"

/* Copy a portion of memory from a source to a destination.
 * @param src           Source address.
 * @param dst           Destination address.
 * @param nbytes        Number of bytes to copy.
 */
void memcpy(uint8_t *src, uint8_t *dst, int nbytes);

/* Set a certain portion of memory to a value.
 * @param dst           Base memory address.
 * @param val           Value to set.
 * @param len           Length of memory portion.
 */
void memset(uint8_t *dst, uint8_t val, uint32_t len);

#endif