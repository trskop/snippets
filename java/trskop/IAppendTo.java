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
package trskop;

import java.io.IOException;
import java.lang.Appendable;


/**
 * Extremly flexible serialization interface.
 *
 * Instead of extending <code>Appendable</code> make object instance of
 * <code>IAppendTo</code> and then it's possible to serialize it in to existing
 * Appendable implementations.
 *
 * @author Peter Trsko
 */
public interface IAppendTo
{
    /**
     * Serialize this object in to specified buffer <code>buff</code> that is
     * exposed only by its <code>Appendable</code> interface.
     *
     * @param buff  Appendable buffer in to which this object will be serialized.
     *
     * @throws IOException  Rethrown from <code>append</code>.
     */
    void appendTo(Appendable buff) throws IOException;
}

// vim: tabstop=4 shiftwidth=4 expandtab filetype=java
