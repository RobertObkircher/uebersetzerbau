#include "panic.h"
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

void panic_fun(const char *file, int line, int exit_code, const char *fmt, ...) {
    va_list args;

    printf("panic %s:%d: ", file, line);

    va_start(args, fmt);
    vprintf(fmt, args);
    va_end(args);

    printf("\n");

    exit(exit_code);
}

