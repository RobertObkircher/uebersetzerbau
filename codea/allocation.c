#include "allocation.h"
#include <malloc.h>
#include "panic.h"

void *malloc_or_exit(size_t size) {
    void *result = malloc(size);
    if (!result)
        panic("out of memory");
    return result;
}

void *calloc_or_exit(size_t nmemb, size_t size) {
    void *result = calloc(nmemb, size);
    if (!result)
        panic("out of memory");
    return result;
}

void *realloc_or_exit(void *ptr, size_t size) {
    void *result = realloc(ptr, size);
    if (!result)
        panic("out of memory");
    return result;
}

void *reallocarray_or_exit(void *ptr, size_t nmemb, size_t size) {
#warning TODO reallocarray_or_exit doesn't check overflow, since reallocarray isn't available on g0
    void *result = realloc(ptr, size); //reallocarray(ptr, nmemb, size);
    if (!result)
        panic("out of memory");
    return result;
}
