/* Copyright (c) 2013, 2014, Peter Trško <peter.trsko@gmail.com>
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *
 *     * Redistributions in binary form must reproduce the above
 *       copyright notice, this list of conditions and the following
 *       disclaimer in the documentation and/or other materials provided
 *       with the distribution.
 *
 *     * Neither the name of Peter Trsko nor the names of other
 *       contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#ifndef MAYBE_H
#define MAYBE_H
/* TODO: Proper guard macro. */

#include <stdint.h>
    /* uint8_t, uint64_t */
#include <stdlib.h>
    /* malloc(), free() */
#include <string.h>
    /* memset() */


#ifdef __cplusplus
extern "C" {
#endif

/* {{{ Declaring maybe structure ******************************************* */

/* We might decide to make this platform dependent. */
typedef uint64_t __nothing_t;

/* When encoding nothing variant then value.nothing should always be set to
 * zero. This prevents some missuses when type is a pointer or zero/NULL
 * terminated array. In any other case never use value.nothing for any purpose.
 */
#define struct_maybe(struct_name, type) \
    struct struct_name {                \
        uint8_t is_just;                \
        union {                         \
            __nothing_t nothing;        \
            type just;                  \
        } value;                        \
    }

#define anonymous_struct_maybe(type)    \
    struct_maybe(, type)

#define typedef_maybe(struct_name, typedef_name, type)  \
    typedef struct_maybe(struct_name, type) typedef_name

#define only_typedef_maybe(typedef_name, type)          \
    typedef_maybe(, typedef_name, type)

#define __maybe_basename(str)           maybe_ ## str
#define __maybe_struct_name(str)        __maybe_basename(str ## _s)
#define __maybe_typedef_name(str)       __maybe_basename(str ## _t)
#define __maybe_ptr_struct_name(str)    __maybe_struct_name(str ## _ptr)
#define __maybe_ptr_typedef_name(str)   __maybe_typedef_name(str ## _ptr)

#define struct_maybe_of(type)           \
    struct_maybe(__maybe_struct_name(type), type)

#define struct_maybe_ptr_of(type)       \
    struct_maybe(__maybe_ptr_struct_name(type), type *)

#define typedef_maybe_of(type)          \
    only_typedef_maybe(__maybe_typedef_name(type), type)

#define typedef_maybe_ptr_of(type)      \
    only_typedef_maybe(__maybe_ptr_typedef_name(type), type *)

/* }}} Declaring maybe structure ******************************************* */

/* {{{ Initializing and setting maybe ************************************** */

/* Example:
 *
 *   typedef_maybe_of(int);
 *   // ----8<----
 *
 *   int main(int argc, char *argv[], char *env[])
 *   {
 *       // ----8<----
 *       maybe_int_t foo = NOTHING;
 *       // ----8<----
 *       foo = (maybe_int_t)NOTHING;
 *       // ----8<----
 *   }
 */
#define NOTHING             \
    { .is_just = 0          \
    , .value.nothing = 0    \
    }

/* Example:
 *
 *   typedef_maybe_of(int);
 *   // ----8<----
 *
 *   int main(int argc, char *argv[], char *env[])
 *   {
 *       // ----8<----
 *       maybe_int_t foo = JUST(42);
 *       // ----8<----
 *       foo = (maybe_int_t)JUST(24);
 *       // ----8<----
 *   }
 */
#define JUST(v)             \
    { .is_just = 1          \
    , .value.just = v       \
    }

/* }}} Initializing and setting maybe ************************************** */

/* {{{ Querying maybe ****************************************************** */

#define is_just(x)          (x.is_just > 0)
#define is_nothing(x)       (x.is_just == 0)
#define from_just(v)        (v.value.just)

#define is_ptr_just(x)      (x->is_just > 0)
#define is_ptr_nothing(x)   (x->is_just == 0)
#define from_ptr_just(v)    (v->value.just)

/* }}} Querying maybe ****************************************************** */

/* {{{ Conditional execution depending on maybe value ********************** */

#define __maybe_cond(x, predicate, on_nothing, on_just)         \
    (predicate(x) ? on_just : on_nothing)

#define __maybe(x, predicate, getter, on_nothing, on_just, ...) \
    __maybe_cond(x, predicate,                                  \
        on_nothing(__VA_ARGS__),                                \
        on_just(getter(x), ##__VA_ARGS__))


#define maybe(v, on_nothing, on_just, ...)      \
    __maybe(v, is_just, from_just, on_nothing, on_just, ##__VA_ARGS__)

#define ptr_maybe(v, on_nothing, on_just, ...)  \
    __maybe(v, is_ptr_just, from_ptr_just, on_nothing, on_just, ##__VA_ARGS__)

#define from_maybe(x, d, on_just, ...)          \
    __maybe_cond(x, is_just, d, on_just(from_just(x), ##__VA_ARGS__)

#define from_ptr_maybe(x, d, on_just, ...)      \
    __maybe_cond(x, is_ptr_just, d, on_just(from_just(x), ##__VA_ARGS__)

/* }}} Conditional execution depending on maybe value ********************** */

/* {{{ Allocating maybes *************************************************** */

#define __alloc_maybe(memset_func, alloc_func, maybe_type)          \
    ((maybe_type *)memset_func(alloc_func(sizeof(maybe_type)), 0,   \
        sizeof(maybe_type)))


#define malloc_struct_maybe_of(type)        \
    __alloc_maybe(memset, malloc, __maybe_struct_name(type))

#define malloc_typedef_maybe_of(type)       \
    __alloc_maybe(memset, malloc, __maybe_typedef_name(type))

#define malloc_struct_maybe_ptr_of(type)    \
    __alloc_maybe(memset, malloc, __maybe_ptr_struct_name(type))

#define malloc_typedef_maybe_ptr_of(type)   \
    __alloc_maybe(memset, malloc, __maybe_ptr_typedef_name(type))

/* }}} Allocating maybes *************************************************** */

/* {{{ Freeing maybes ****************************************************** */

#define __free_just(free_func, maybe)               \
    free_func(from_just(maybe))                     \

#define __free_ptr_just(free_func, maybe_ptr)       \
    free_func(from_ptr_just(maybe_ptr))             \

/* Helper macro for reducing repetition */
#define __on_true_do(x, predicate, action, arg0)    \
    do {                                            \
        if (predicate(x))                           \
        {                                           \
            action(arg0, x);                        \
        }                                           \
    } while (0)

#define free_just(maybe)                            \
    __on_true_do(maybe, is_just, __free_just, free)

#define free_ptr_just(maybe_ptr)                    \
    __on_true_do(maybe_ptr, is_ptr_just, __free_ptr_just, free)

#define __free_maybe_ptr(free_func, maybe_ptr)      \
    do {                                            \
        __on_true_do(maybe_ptr, is_ptr_just,        \
            __free_ptr_just, free_func);            \
        free_func(maybe_ptr);                       \
    } while (0)

#define free_maybe_ptr(maybe_ptr)                   \
    __free_maybe_ptr(free, maybe_ptr)

/* }}} Freeing maybes ****************************************************** */

#ifdef __cplusplus
}
#endif

#endif /* MAYBE_H */

/* vim: tabstop=4 shiftwidth=4 expandtab
 */
