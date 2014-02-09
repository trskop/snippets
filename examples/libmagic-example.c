/* Copyright (c) 2014, Peter Trško <peter.trsko@gmail.com>
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

/* Example of using libmagic.
 *
 * Compile with:
 *
 *   gcc --std=c99 libmagic-example.c -lmagic -o libmagic-example
 *
 * On Debian/Ubuntu you might need to install libmagic-dev package:
 *
 *   apt-get install libmagic-dev
 */
#include <stdio.h>
#include <magic.h>
#include <stdlib.h>


struct magic_flag_s { 
    int value;
    char *string;
};

#define mk_magic_flag(flag)    {flag, #flag}

int main(int argc, char *argv[])
{
    const char *magic_result;
    magic_t magic_cookie;
    int ret = EXIT_FAILURE;
    const int MAGIC_FLAGS_LENGTH = 3;
    struct magic_flag_s magic_flags[] = {
        mk_magic_flag(MAGIC_NONE),
        mk_magic_flag(MAGIC_MIME),
        mk_magic_flag(MAGIC_MIME_ENCODING),
    };

    // Function magic_open() takes flags that modify libmagic's behaviour, but
    // they can be modified later by using function magic_setflags().
    magic_cookie = magic_open(MAGIC_NONE); 
    if (magic_cookie == NULL)
    {
        printf("Unable to initialize libmagic.\n");
        goto fail;
    }

    // NULL - Using default database, it is possible to specify your own.
    if (magic_load(magic_cookie, NULL) != 0)
    {
        printf("Failed while loading magic database: %s\n",
            magic_error(magic_cookie));
        goto fail_with_cleanup;
    }

    for (int i = 1; i < argc; i++)
    {
        for (int j = 0; j < MAGIC_FLAGS_LENGTH; j++)
        {
            magic_setflags(magic_cookie, magic_flags[j].value);

            // I'm assuming that magic_file() returns pointer to some allocated
            // memmory associated with magic_cookie and therefore it's not
            // necessary to dealocate it afterwards.
            magic_result = magic_file(magic_cookie, argv[i]);
            if (magic_result != NULL)
            {
                printf("Result with %s flag: %s\n",
                    magic_flags[j].string, magic_result);
            }
        }
    }
    ret = EXIT_SUCCESS;

fail_with_cleanup:
    magic_close(magic_cookie);

fail:
    return ret;
}
