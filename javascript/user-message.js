// Copyright (c) 2013, Peter Trsko <peter.trsko@gmail.com>
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following
// disclaimer in the documentation and/or other materials provided
// with the distribution.
//
// * Neither the name of Peter Trsko nor the names of other
// contributors may be used to endorse or promote products derived
// from this software without specific prior written permission.
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


;(function(namespace, window, $, undefined) {
  // These variables allow better minification:
  var CLEAR = "clear";
  var DEFAULT_CLASS = "defaultClass";
  var FACTORY = "factory";
  var IS_KNOWN_MESSAGE_CLASS = "isKnownMessageClass";
  var SHOW = "show";

  function getter(t, k, v)
  {
    var defGetter = t.__defineGetter__;

    if (defGetter)
    {
      defGetter.call(t, k, function() {return v;});
    }
    else
    {
      t[k] = v;
    }
  }

  function constructUserMessage(cls)
  {
    // Constants.
    var _class =
      { ERROR: 'error'
      , WARNING: 'warning'
      , OK: 'ok'
      , INFO: 'info'
      , NONE: 'none'
      };
    var _defaultClass = _class.INFO;

    // Variables that needs to be initialized before usage.
    var _classValues = {};  // Map with key-value reversed.
    var _classesStr = '';   // Message classes separated by white space.

    // Populate _classValues and generate _classesStr.
    for (var key in _class)
    {
      var val = _class[key];

      _classValues[val] = key;
      _classesStr += _classesStr ? ' ' + val : val;
    }

    function _isKnownMessageClass(msgCls)
    {
      return _classValues.hasOwnProperty(msgCls);
    }

    /**
     * function _implementation(selector: string
     *   [, defaultMessageClass: string = UserMessage.INFO
     *   [[, messageClass: string]
     *   , message: string | object | array]): undefined
     */
    function _implementation(selector, defaultMessageClass, messageClass,
      message)
    {
      // If undefined or null passed as a message class then default is used.
      if (defaultMessageClass === undefined || defaultMessageClass === null)
      {
        defaultMessageClass = _class.INFO;
      }

      // Argument messageClass is optional, if so then message is passed as a
      // third argument. Exception is when messageClass is equal to _class.NONE
      // then message argument is ignored.
      if (messageClass === _class.NONE)
      {
        message = "";
      }
      else if (message === undefined)
      {
        // Shift arguments by one
        message = messageClass;
        messageClass = undefined; // Default message class is set bewlow.
      }

      // If message is still not defined or null, then we are clearing message
      // box. This can happen when explicitly passing null as message argument
      // or if both messageClass and message aren't passed during function
      // call.
      if (message === undefined || message === null)
      {
        messageClass = _class.NONE;
      }

      // Fallback is always default message class.
      if (!_isKnownMessageClass(messageClass))
      {
        // Unknown message class, using default.
        messageClass = defaultMessageClass;
      }

      if (typeof message !== 'string')
      {
        if (typeof message === 'object')
        {
          message = message.toString();
        }
        else if ($.isArray(message))
        {
          message = message.join(' ');
        }
        else
        {
          ; // TODO throw exception
        }
      }

      $(selector).removeClass(_classesStr).addClass(messageClass).text(message);
    }

    /**
     * function _factory(selector: string
     *   [, defaultMessageClass: string]): undefined
     */
    function _factory(selector, defaultMessageClass)
    {
      // function([[messageClass: string, ]
      //   message: string | object | array]): undefined

      return function (messageClass, message) {
        _implementation(selector, defaultMessageClass, messageClass, message);
      };
    }

    /**
     * function _clear(selector: string
     *   [, messageClass: string = UserMessage.NONE]): undefined
     */
    function _clear(selector, messageClass)
    {
      if (messageClass === undefined
        || messageClass == null
        || !_isKnownMessageClass(messageClass))
      {
        messageClass = _class.NONE;
      }

      $(selector).removeClass(_classesStr).addClass(messageClass).text("");
    }

    function _show(selector, messageClass, message)
    {
      _implementation(selector, undefined, messageClass, message);
    };

    for (var msgCls in _class)
    {
      getter(cls, msgCls, _class[msgCls]);
    }
    getter(cls, DEFAULT_CLASS, _defaultClass);
    getter(cls, IS_KNOWN_MESSAGE_CLASS, _isKnownMessageClass);
    getter(cls, FACTORY, _factory);
    getter(cls, CLEAR, _clear);
    getter(cls, SHOW, _show);

    return cls;
  }

  /**
   * UserMessage.ERROR: string
   * UserMessage.WARNING: string
   * UserMessage.OK: string
   * UserMessage.INFO: string
   * UserMessage.NONE: string
   * UserMessage.defaultClass: string
   *
   * var userMessage = new trskop.UserMessage(selector: string
   *   [, defaultMessageClass: string = UserMessage.INFO]);
   *
   * userMessage.clear([messageClass: string = trskop.UserMessage.NONE]):
   *   undefined
   *
   * userMessage.show([[messageClass: string = trskop.UserMessage.INFO, ]
   *   message: string | object | array]): undefined
   *
   * userMessage.defaultClass: string
   *
   * selector
   *
   *   The jQuery (CSS) selector of element that should be handled by instance
   *   of this class.
   *
   * messageClass, defaultMessageClass
   *
   *   CSS class of the message and it should be one of:
   *
   *   * UserMessage.ERROR
   *   * UserMessage.WARNING
   *   * UserMessage.OK
   *   * UserMessage.INFO (default for messages)
   *   * UserMessage.NONE (default for clear())
   *
   * message
   *
   *   Message to be shown if message class is different then
   *   UserMessage.NONE, otherwise it's ignored.
   *
   * Calling show() (without arguments) behaves the same way as calling clear()
   * (whitout arguments).
   */
  function UserMessage(selector, defaultMessageClass)
  {
    var _defaultClass = defaultMessageClass || UserMessage.defaultClass;
    var _show = UserMessage.factory(selector, defaultMessageClass);
    var _clear = function(messageClass) {
      // function([messageClass: string = UserMessage.NONE]): undefined
      UserMessage.clear(selector, messageClass);
    };

    getter(this, CLEAR, _clear);
    getter(this, DEFAULT_CLASS, _defaultClass);
    getter(this, SHOW, _show);
  }

  namespace.UserMessage = constructUserMessage(UserMessage);
})(window.trskop = window.trskop || {}, window, jQuery);

// vim:ts=2 sw=2 expandtab
