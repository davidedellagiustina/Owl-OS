// @desc     Kernel
// @author   Davide Della Giustina
// @date     07/12/2019

#include <stdint.h>
#include "../cpu/isr.h"
#include "../cpu/paging.h"
#include "../drivers/vga.h"
#include "heap.h"
#include "processes.h"

/* Print "ScratchOS" ASCII art.
 */
void print_ascii_art() {
    kprint(" ____                 _       _      ___  ____\n");
    kprint("/ ___|  ___ _ __ __ _| |_ ___| |__  / _ \\/ ___|\n");
    kprint("\\___ \\ / __| '__/ _` | __/ __| '_ \\| | | \\___ \\\n");
    kprint(" ___) | (__| | | (_| | || (__| | | | |_| |___) |\n");
    kprint("|____/ \\___|_|  \\__,_|\\__\\___|_| |_|\\___/|____/");
}

extern page_directory_t *kernel_directory;

/* Kernel main.
 * @param kvs       Kernel start virtual address.
 * @param kve       Kernel end virtual address.
 * @param kps       Kernel start physical address.
 * @param kpe       Kernel end physical address.
 */
void kmain(void *kvs, void *kve, physaddr_t kps, physaddr_t kpe) {
    clear_screen();
    kprint("Booting ScratchOS v0.1...\n\n");
    // Print some kernel info
    uint32_t kernel_size = ((kpe - kps) / 1024) - 4; // In KB, subtracting the size of kernel stack
    char buf[10]; itoa(kps, buf, 16);
    kprint("Kernel location: 0x"); kprint(buf); kprint(" - ");
    itoa(kpe, buf, 16);
    kprint("0x"); kprint(buf); kprint(".\n");
    itoa(kernel_size, buf, 10);
    kprint("Kernel approximate size: "); kprint(buf); kprint("KB.\n");
    // Install interrupt handlers
    kprint("Installing interrupt vector and handlers...");
    isr_install();
    irq_init();
    kprint(" Done!\n");
    // Setup paging
    kprint("Setting up paging...");
    setup_paging(kvs, kve, kps, kpe);
    kprint(" Done!\n");
    // Setup kernel heap
    kprint("Setting up kernel heap...");
    kheap_init();
    kprint(" Done!\n");
    // Setup scheduling queue
    // kprint("Setting up scheduling queue and structures...");
    // processes_init();
    // kprint(" Done!\n");
    // Launch init process
    // kprint("Launching the init process...");
    // launch_init(); // Activate scheduler (init will be started)

    // TEMP: Basic shell-like interface here
    clear_screen();
    print_ascii_art();
    kprint("\n\n> ");
}