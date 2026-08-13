#define _GNU_SOURCE

#include <dlfcn.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <unistd.h>

static void record_path(const char *operation, const char *path)
{
    const char *trace_path = getenv("ORACLE_FILE_TRACE");
    char line[4096];
    int fd;
    int length;

    if (trace_path == NULL || path == NULL) {
        return;
    }

    fd = syscall(
        SYS_openat,
        AT_FDCWD,
        trace_path,
        O_WRONLY | O_CREAT | O_APPEND | O_CLOEXEC,
        0644
    );
    if (fd < 0) {
        return;
    }

    length = snprintf(line, sizeof(line), "%s\t%s\n", operation, path);
    if (length > 0) {
        size_t bytes = (size_t) length < sizeof(line)
            ? (size_t) length
            : sizeof(line) - 1;
        syscall(SYS_write, fd, line, bytes);
    }
    syscall(SYS_close, fd);
}

static mode_t read_mode(int flags, va_list arguments)
{
    if ((flags & O_CREAT) != 0 || (flags & O_TMPFILE) == O_TMPFILE) {
        return (mode_t) va_arg(arguments, int);
    }
    return 0;
}

int open(const char *path, int flags, ...)
{
    static int (*next_open)(const char *, int, ...) = NULL;
    va_list arguments;
    mode_t mode;

    va_start(arguments, flags);
    mode = read_mode(flags, arguments);
    va_end(arguments);
    if (next_open == NULL) {
        next_open = dlsym(RTLD_NEXT, "open");
    }
    record_path("open", path);
    return next_open(path, flags, mode);
}

int open64(const char *path, int flags, ...)
{
    static int (*next_open64)(const char *, int, ...) = NULL;
    va_list arguments;
    mode_t mode;

    va_start(arguments, flags);
    mode = read_mode(flags, arguments);
    va_end(arguments);
    if (next_open64 == NULL) {
        next_open64 = dlsym(RTLD_NEXT, "open64");
    }
    record_path("open64", path);
    return next_open64(path, flags, mode);
}

int openat(int directory, const char *path, int flags, ...)
{
    static int (*next_openat)(int, const char *, int, ...) = NULL;
    va_list arguments;
    mode_t mode;

    va_start(arguments, flags);
    mode = read_mode(flags, arguments);
    va_end(arguments);
    if (next_openat == NULL) {
        next_openat = dlsym(RTLD_NEXT, "openat");
    }
    record_path("openat", path);
    return next_openat(directory, path, flags, mode);
}

int openat64(int directory, const char *path, int flags, ...)
{
    static int (*next_openat64)(int, const char *, int, ...) = NULL;
    va_list arguments;
    mode_t mode;

    va_start(arguments, flags);
    mode = read_mode(flags, arguments);
    va_end(arguments);
    if (next_openat64 == NULL) {
        next_openat64 = dlsym(RTLD_NEXT, "openat64");
    }
    record_path("openat64", path);
    return next_openat64(directory, path, flags, mode);
}

FILE *fopen(const char *path, const char *mode)
{
    static FILE *(*next_fopen)(const char *, const char *) = NULL;

    if (next_fopen == NULL) {
        next_fopen = dlsym(RTLD_NEXT, "fopen");
    }
    record_path("fopen", path);
    return next_fopen(path, mode);
}

FILE *fopen64(const char *path, const char *mode)
{
    static FILE *(*next_fopen64)(const char *, const char *) = NULL;

    if (next_fopen64 == NULL) {
        next_fopen64 = dlsym(RTLD_NEXT, "fopen64");
    }
    record_path("fopen64", path);
    return next_fopen64(path, mode);
}

FILE *freopen(const char *path, const char *mode, FILE *stream)
{
    static FILE *(*next_freopen)(const char *, const char *, FILE *) = NULL;

    if (next_freopen == NULL) {
        next_freopen = dlsym(RTLD_NEXT, "freopen");
    }
    record_path("freopen", path);
    return next_freopen(path, mode, stream);
}

FILE *freopen64(const char *path, const char *mode, FILE *stream)
{
    static FILE *(*next_freopen64)(const char *, const char *, FILE *) = NULL;

    if (next_freopen64 == NULL) {
        next_freopen64 = dlsym(RTLD_NEXT, "freopen64");
    }
    record_path("freopen64", path);
    return next_freopen64(path, mode, stream);
}
