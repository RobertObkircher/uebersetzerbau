#ifndef __PANIC_H__
#define __PANIC_H__

#define panic(...) panic_fun(__FILE__, __LINE__, 42, __VA_ARGS__)
#define panic3(...) panic_fun(__FILE__, __LINE__, 3, __VA_ARGS__)
#define panic2(...) panic_fun(__FILE__, __LINE__, 2, __VA_ARGS__)
#define panic1(...) panic_fun(__FILE__, __LINE__, 1, __VA_ARGS__)

void panic_fun(const char *file, int line, int exit_code, const char *fmt, ...);

#endif
