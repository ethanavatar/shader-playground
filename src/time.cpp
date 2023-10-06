#if __WIN32__
    #include <__msvc_chrono.hpp>
#endif // __WIN32__

#include <stdint.h>

#if !defined(_WIN32) && !defined(_WIN64) // Linux - Unix
    #include <sys/time.h>
    typedef timeval sys_time_t;
    inline void system_time(sys_time_t* t) {
        gettimeofday(t, NULL);
    }
    inline uint64_t time_to_msec(const sys_time_t& t) {
        return t.tv_sec * 1000LL + t.tv_usec / 1000;
    }
#else // Windows and MinGW
    #include <sys/timeb.h>
    typedef _timeb sys_time_t;
    inline void system_time(sys_time_t* t) { _ftime(t); }
    inline uint64_t time_to_msec(const sys_time_t& t) {
        return t.time * 1000LL + t.millitm;
    }
#endif

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

    uint64_t get_milis(void) {
        sys_time_t t;
        system_time(&t);
        return time_to_msec(t);
    }

#ifdef __cplusplus
}
#endif // __cplusplus
