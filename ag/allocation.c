#include "allocation.h"
#include <malloc.h>

static void panic() {
    perror("out of memory");
    exit(42);
}

void *malloc_or_exit(size_t size) {
    void *result = malloc(size);
    if (!result)
        panic();
    return result;
}

void *calloc_or_exit(size_t nmemb, size_t size) {
    void *result = calloc(nmemb, size);
    if (!result)
        panic();
    return result;
}

void *realloc_or_exit(void *ptr, size_t size) {
    void *result = realloc(ptr, size);
    if (!result)
        panic();
    return result;
}

void *reallocarray_or_exit(void *ptr, size_t nmemb, size_t size) {
    void *result = reallocarray(ptr, nmemb, size);
    if (!result)
        panic();
    return result;
}
