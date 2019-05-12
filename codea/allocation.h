#ifndef ALLOCATION_H
#define ALLOCATION_H

#include <stdlib.h>

void *malloc_or_exit(size_t size);

void *calloc_or_exit(size_t nmemb, size_t size);

void *realloc_or_exit(void *ptr, size_t size);

void *reallocarray_or_exit(void *ptr, size_t nmemb, size_t size);

#endif
