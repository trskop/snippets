/* Copyright (c) 2013, Peter Trško <peter.trsko@gmail.com>
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


#ifdef __cplusplus
extern "C" {
#endif

/* Declaring maybe structure */

#define struct_maybe(name, type)        \
    struct name {                       \
        uint8_t is_just;                \
        union {                         \
            uint64_t nothing;           \
            type just;                  \
        } value;                        \
    }

#define anonymous_struct_maybe(type)    \
    struct_maybe(, type)

#define struct_maybe_of(type)           \
    struct_maybe(maybe_ ## type ## _s, type)

#define struct_maybe_ptr_of(type)       \
    struct_maybe(maybe_ ## type ## _ptr_s, type *)

/* Setting maybe */

#define NOTHING             \
    { .is_just = 0          \
    , .value.nothing = 0    \
    }

#define JUST(v)             \
    { .is_just = 1          \
    , .value.just = v       \
    }

/* Querying maybe */

#define is_just(x)          (x.is_just > 0)
#define is_nothing(x)       (x.is_just == 0)
#define from_just(v)        (v.value.just)

#define is_ptr_just(x)      (x->is_just > 0)
#define is_ptr_nothing(x)   (x->is_just == 0)
#define from_ptr_just(v)    (v->value.just)

/* Conditional execution depending on maybe value */

#define __maybe_cond(x, predicate, on_nothing, on_just)         \
    (predicate(x) ? on_just : on_nothing)

#define __maybe(x, predicate, getter, on_nothing, on_just, ...) \
    __maybe_cond(x, predicate, on_nothing(__VA_ARGS__),         \
        on_just(getter(x), ##__VA_ARGS__))

#define maybe(v, on_nothing, on_just, ...)      \
    __maybe(v, is_just, from_just, on_nothing, on_just, ##__VA_ARGS__)

#define ptr_maybe(v, on_nothing, on_just, ...)  \
    __maybe(v, is_ptr_just, from_ptr_just, on_nothing, on_just, ##__VA_ARGS__)

#define from_maybe(x, d, on_just, ...)          \
    __maybe_cond(x, is_just, d, on_just(from_just(x), ##__VA_ARGS__)

#define from_ptr_maybe(x, d, on_just, ...)      \
    __maybe_cond(x, is_ptr_just, d, on_just(from_just(x), ##__VA_ARGS__)

#ifdef __cplusplus
}
#endif

#endif /* MAYBE_H */

/* vim: tabstop=4 shiftwidth=4 expandtab
 */
