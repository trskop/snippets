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
  function get(x)
  {
    return function() {
      return x;
    };
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
    var _classesStr = '';

    // Populate _classValues and generate _classesStr.
    for (var key in _class)
    {
      var val = _class[key];

      _classValues[val] = key;
      if (_classesStr)
      {
        _classesStr += ' ';
      }
      _classesStr += val;
    }

    function _isKnownMessageClass(msgCls)
    {
      return _classValues.hasOwnProperty(msgCls);
    }

    /**
     * function _implementation(selector: string,
     *     defaultMessageClass = UserMessage.INFO: string,
     *     [messageClass: string],
     *     message: string | object | array)
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

    function _factory(selector, defaultMessageClass)
    {
      return function (messageClass, message) {
        // function([messageClass: string], message: string | object): undefined
        //
        // messageClass
        //
        //   CSS class of the message and it should be one of:
        //   UserMessage.ERROR
        //   UserMessage.WARNING
        //   UserMessage.OK
        //   UserMessage.INFO
        //   UserMessage.NONE
        //
        // message
        //
        //   Message to be shown if message class is different then
        //   UserMessage.NONE, otherwise it's ignored.
        _implementation(selector, defaultMessageClass, messageClass, message);
      };
    }

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

    if (cls.__defineGetter__)
    {
      for (var msgCls in _class)
      {
        cls.__defineGetter__(msgCls, get(_class[msgCls]));
      }
      cls.__defineGetter__('defaultClass', get(_defaultClass));
      cls.__defineGetter__('isKnownMessageClass', get(_isKnownMessageClass));
      cls.__defineGetter__('factory', get(_factory));
      cls.__defineGetter__('clear', get(_clear));
      cls.__defineGetter__('show', get(_show));
    }
    else
    {
      for (var msgCls in _class)
      {
        cls[msgCls] = _class[msgcls];
      }
      cls.defaultClass = _defaultClass;
      cls.isKnownMessageClass = _isKnownMessageClass;
      cls.factory = _factory;
      cls.clear = _clear;
      cls.show = _show;
    }

    return cls;
  }

  function UserMessage(selector, defaultMessageClass, initialMessageClass)
  {
    var _show = UserMessage.factory(selector, defaultMessageClass);
    var _clear = function() {
      UserMessage.clear(selector);
    };

    if (this.__defineGetter__)
    {
      this.__defineGetter__('show', get(_show));
      this.__defineGetter__('clear', get(_clear));
    }
    else
    {
      this.show = _show;
      this.clear = _clear;
    }
  }

  namespace.UserMessage = constructUserMessage(UserMessage);
})(window.trskop = window.trskop || {}, window, jQuery);

// vim:ts=2 sw=2 expandtab
