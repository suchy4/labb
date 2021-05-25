//
// Created by Roman Wiatr on 18/05/2021.
//

#ifndef CUDA_INTRODUCTION_UTIL_CUH
#define CUDA_INTRODUCTION_UTIL_CUH
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <stdint.h> // portable: uint64_t   MSVC: __int64

// MSVC defines this in winsock2.h!?
typedef struct timeval {
    long tv_sec;
    long tv_usec;
} timeval;

int gettimeofday(struct timeval * tp, struct timezone * tzp)
{
    // Note: some broken versions only have 8 trailing zero's, the correct epoch has 9 trailing zero's
    // This magic number is the number of 100 nanosecond intervals since January 1, 1601 (UTC)
    // until 00:00:00 January 1, 1970
    static const uint64_t EPOCH = ((uint64_t) 116444736000000000ULL);

    SYSTEMTIME  system_time;
    FILETIME    file_time;
    uint64_t    time;

    GetSystemTime( &system_time );
    SystemTimeToFileTime( &system_time, &file_time );
    time =  ((uint64_t)file_time.dwLowDateTime )      ;
    time += ((uint64_t)file_time.dwHighDateTime) << 32;

    tp->tv_sec  = (long) ((time - EPOCH) / 10000000L);
    tp->tv_usec = (long) (system_time.wMilliseconds * 1000);
    return 0;
}
void checkErrors(char *label) {
// we need to synchronise first to catch errors due to
// asynchroneous operations that would otherwise
// potentially go unnoticed
    cudaError_t err;
    err = cudaThreadSynchronize();
    if (err != cudaSuccess) {
        char *e = (char *) cudaGetErrorString(err);
        fprintf(stderr, "CUDA Error: %s (at %s)\n", e, label);
    }
    err = cudaGetLastError();
    if (err != cudaSuccess) {
        char *e = (char *) cudaGetErrorString(err);
        fprintf(stderr, "CUDA Error: %s (at %s)\n", e, label);
    }
}

double get_time() {
    struct timeval tim;
    cudaThreadSynchronize();
    gettimeofday(&tim, NULL);
    return (double) tim.tv_sec + (tim.tv_usec / 1000000.0);
}

#endif //CUDA_INTRODUCTION_UTIL_CUH
