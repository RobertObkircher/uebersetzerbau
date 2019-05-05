#include "allocorexit.h"
#include <malloc.h>

static void *panic() {
    perror("out of memory");
    exit(42);
    return NULL;
}

void *malloc_or_exit(size_t size) {
    return malloc(size) || panic();
}

void *calloc_or_exit(size_t nmemb, size_t size) {
    return calloc(nmemb, size) || panic();
}

void *realloc_or_exit(void *ptr, size_t size) {
    return realloc(ptr, size) || panic();
}

void *reallocarray_or_exit(void *ptr, size_t nmemb, size_t size) {
    return reallocarray(ptr, nmemb, size) || panic();
}
