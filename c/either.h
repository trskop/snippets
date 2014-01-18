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
#ifndef EITHER_H
#define EITHER_H

#ifdef __cplusplus
extern "C" {
#endif

/* {{{ Declaring either structure ****************************************** */

#define struct_either(struct_name, left_type, right_type)   \
    struct struct_name {                                    \
        uint8_t is_right;                                   \
        union {                                             \
            left_type left;                                 \
            right_type right;                               \
        } value;                                            \
    }

#define anonymous_struct_either(left_type, right_type)      \
    struct_either(, left_type, right_type)

#define typedef_either(struct_name, typedef_name, left_type, right_type)    \
    typedef struct_either(struct_name, left_type, right_type) typedef_name

#define only_typedef_either(typedef_name, left_type, right_type)    \
    typedef_either(, typedef_name, left_type, right_type)

#define __either_basename(lstr, rstr)       either_ ## lstr ## _or_ ## rstr
#define __either_struct_name(lstr, rstr)    __either_basename(lstr, rstr ## _s)
#define __either_typedef_name(lstr, rstr)   __either_basename(lstr, rstr ## _t)

#define struct_either_of(left_type, right_type)                         \
    struct_either(__either_struct_name(left_type, right_type),          \
        left_type, right_type)

#define typedef_either_of(left_type, right_type)                        \
    only_typedef_either(__either_typedef_name(left_type, right_type),   \
        left_type, right_type)

/* }}} Declaring either structure ****************************************** */

/* {{{ Initializing and setting either ************************************* */

#define LEFT(v)             \
    { .is_right = 0         \
    , .value.left = v       \
    }

#define RIGHT(v)            \
    { .is_right = 1         \
    , .value.right = v      \
    }

/* }}} Initializing and setting either ************************************* */

/* {{{ Querying either ***************************************************** */

#define is_left(x)      (x.is_right == 0)
#define is_right(x)     (x.is_right > 0)
#define from_left(x)    (x.value.left)
#define from_right(x)   (x.value.right)

#define is_ptr_left(x)      (x->is_right == 0)
#define is_ptr_right(x)     (x->is_right > 0)
#define from_ptr_left(x)    (x->value.left)
#define from_ptr_right(x)   (x->value.right)

/* }}} Querying either ***************************************************** */

/* {{{ Conditional execution depending on either value ********************* */

#define __either_cond(x, predicate, on_left, on_right)      \
    (predicate(x) ? on_left : on_right)

#define __either(x, predicate, l_getter, r_getter, on_left, on_right, ...)  \
    __either_cond(x, predicate,                                             \
        on_left(l_getter(x), __VA_ARGS__),                                  \
        on_right(r_getter(x), ##__VA_ARGS__))

#define either(x, on_left, on_right, ...)   \
    __either(x,                             \
        is_left, from_left, from_right,     \
        on_left, on_right, ##__VA_ARGS__)

#define ptr_either(x, on_left, on_right, ...)       \
    __either(x,                                     \
        is_ptr_left, from_ptr_left, from_ptr_right, \
        on_left, on_right, ##__VA_ARGS__)

/* }}} Conditional execution depending on either value ********************* */

#ifdef __cplusplus
}
#endif

#endif /* EITHER_H */

/* vim: tabstop=4 shiftwidth=4 expandtab
 */
