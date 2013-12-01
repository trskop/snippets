// Copyright (c) 2013, Peter Trsko <peter.trsko@gmail.com>
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright
//   notice, this list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above
//   copyright notice, this list of conditions and the following
//   disclaimer in the documentation and/or other materials provided
//   with the distribution.
//
// * Neither the name of Peter Trsko nor the names of other
//   contributors may be used to endorse or promote products derived
//   from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

'use strict';

;(function(namespace, window, undefined) {
  var FUNCTION_STR = 'function';
  var WITH_EXTEND_STR = 'withExtend';
  var WITH_TO_JSON_STR = 'withToJson';
  var WITH_TO_JSON_SIMPLE_STR = 'withToJsonSimple';

  // Utility functions ////////////////////////////////////////////////////////

  function defineGetter(obj, name, val)
  {
    var def = obj.__defineGetter__;

    if (def)
    {
      def.call(obj, name, function() {
        return val;
      });
    }
    else
    {
      obj[name] = func;
    }
  }

  function assertFunction(contextOfFunction, f)
  {
    if (typeof f !== FUNCTION_STR)
    {
      throw new TypeError(contextOfFunction + "(): Expecting function.");
    }
  }


  // JSON /////////////////////////////////////////////////////////////////////

  function withToJson(obj, toJson)
  {
    assertFunction(WITH_TO_JSON_STR, toJson);
    defineGetter(obj, 'toJson', toJson);

    return obj;
  }

  function withToJsonSimple(obj, toObj)
  {
    assertFunction(WITH_TO_JSON_SIMPLE_STR, toObj);

    return withToJson(obj, function() {
      return JSON.stringify(toObj());
    });
  }

  namespace[WITH_TO_JSON_STR] = withToJson;
  namespace[WITH_TO_JSON_SIMPLE_STR] = withToJsonSimple;


  // Extend ///////////////////////////////////////////////////////////////////

  function extend(classConstructor, props)
  {
    var parent = this;
    var child;

    if (props && props.hasOwnProperty('constructor'))
    {
      child = props.constructor;
    }
    else
    {
      child = function() {
        return parent.call(this, props);
      };
    }

    if (classConstructor)
    {
      classConstructor.call(this, child);
    }

    if (props && props.hasOwnProperty('classConstructor'))
    {
      props.classConstructor.call(child, parent, props);
    }

    function Surrogate()
    {
      this.constructor = child;
    }

    Surrogate.prototype = parent.prototype;
    child.prototype = new Surrogate();
    defineGetter(child, 'super', parent);

    return child;
  }

  namespace[WITH_EXTEND_STR] = function(classConstructor, obj)
  {
    if (obj === undefined)
    {
      obj = classConstructor;
      classConstructor = undefined;
    }
    else
    {
      assertFunction(WITH_EXTEND_STR, classConstructor);
    }

    defineGetter(obj, 'extend', function(props) {
      return extend.call(obj, classConstructor, props);
    });

    return obj;
  }
})((function() {
  window.trskop = window.trskop || {};
  window.trskop.generics = window.trskop.generics || {};
  return window.trskop.generics;
})(), window);

// vim:ts=2 sw=2 expandtab
