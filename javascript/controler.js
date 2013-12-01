// Copyright (c) 2012, 2013, Peter Trsko <peter.trsko@gmail.com>
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
// These variables allow better minification:
var CONTEXT_STR = 'context';
var FAILURE_STR = 'failure';
var FUNCTION_STR = 'function';
var NUMBER_STR = 'number';
var OBJECT_STR = 'object';
var STATE_STR = 'state';
var STRING_STR = 'string';
var SUCCESS_STR = 'success';

var withToJson =
  namespace.generics
  ? namespace.generics.withToJson
  : function(obj) {
      return obj;
    };
var withExtend =
  namespace.generics
  ? namespace.generics.withExtend
  : function(clsConstr, obj) {
    return obj;
  };

/**
 * function(obj: function | object, key: string, val: *
 *   [, fun: function]): undefined
 *
 * Construct and define a getter for specified object. This lowers code
 * redundancy and as a side effect we get smaller minimized code.
 */
function defineGetter(obj, key, val, fun)
{
  var defGetter = obj.__defineGetter__;

  if (defGetter)
  {
    var f = function() {return val;};

    if (val === undefined)
    {
      f = fun;
    }

    defGetter.call(obj, key, f);
  }
  else
  {
    obj[key] = val === undefined ? val : fun;
  }
}

function NoSuchStateError(message)
{
  this.name = 'NoSuchStateError';
  this.message = message;
}
NoSuchStateError.prototype = new Error();
NoSuchStateError.constructor = NoSuchStateError;

/* TODO: Use it.
function DuplicateKeyError(message)
{
  this.name = 'DuplicateKeyError';
  this.message = message;
}
DuplicateKeyError.prototype = new Error();
DuplicateKeyError.constructor = DuplicateKeyError;
*/

function StateChangeEvent(when, leavingState, enteringState, oldStateChangeEvent)
{
  var _attrs =
    { hasFailed: oldStateChangeEvent ? oldStateChangeEvent.hasFailed : false
    };

  defineGetter(this, 'when', when);
  defineGetter(this, 'leavingState', leavingState);
  defineGetter(this, 'enteringState', enteringState);
  defineGetter(this, 'hasFailed', undefined, function() {
    return _attrs.hasFailed;
  });
  defineGetter(this, 'fail', function() {
    _attrs.hasFailed = true;
  });

  withToJson(this, function() {
    return JSON.stringify(
      { when: when
      , leavingState: leavingState
      , enteringState: enteringState
      , hasFailed: _attrs.hasFailed
      });
  });
}

function Controler(context, description)
{
  // Callbacks
  var _callbacks =
    { leave: []       // List of lists of callbacks, first index is state.
    , preEnter: []    // List of callbacks.
    , enter: []       // List of lists of callbacks, first index is state.
    , postEnter: []   // List of callbacks
    };
  var _globalCallbacks = {};
  _globalCallbacks[SUCCESS_STR] = null;   // Global success handler.
  _globalCallbacks[FAILURE_STR] = null;   // Global failure handler.

  var _context = context || {};
  var _currentState = null;
  var _stateId = [];
  var _states = {};
  var _stateConstants = {};

  for (var callbackType in _globalCallbacks)
  {
    (function(callbackType) { // Cloasure for callbackType
      defineGetter(this, callbackType, undefined, function() {
        return _globalCallbacks[callbackType];
      });
      if (this.__defineSetter__)
      {
        this.__defineSetter__(callbackType, function(v) {
          if (typeof v == FUNCTION_STR)
          {
            _globalCallbacks[callbackType] = v;
          }
        });
      }
    }).call(this, callbackType);
  }
  defineGetter(this, CONTEXT_STR, _context);
  defineGetter(this, STATE_STR, undefined, function() {
    return _currentState;
  });
  defineGetter(this, 'stateName', undefined, function() {
    return _stateId[_currentState];
  });

  /**
   * function _stateExists(state: number | string | object): bool
   *     throws TypeError
   *
   * If state argument is an object than it has to have a toString() method
   * which will be used to get string representation.
   */
  function _stateExists(state)
  {
    /* Check if numeric state ID or state name is valid. */
    switch (typeof state)
    {
      case NUMBER_STR: /* Numeric state ID. */
        return state >= 0 && state < _stateId.length;
      case STRING_STR: /* State name as used during registration. */
        return _states.hasOwnProperty(state);
      default:
        if (state && state.toString && typeof state.toString == FUNCTION_STR)
        {
          return _states.hasOwnProperty(state.toString());
        }
        else
        {
          throw new TypeError(STATE_STR + ': Expecting ' + NUMBER_STR + ', '
            + STRING_STR + ' or ' + OBJECT_STR + ' with toString method');
        }
    }
  }
  defineGetter(this, 'stateExists', _stateExists);

  /**
   * function _checkState(state: number | string | object): undefined
   *     throws TypeError, NoSuchStateError
   *
   * Check if state is valid numeric state ID or state name and if not then
   * throw exception.
   *
   * This function is useful as an assertation.
   */
  function _checkState(state)
  {
    if (!_stateExists(state))
    {
      throw new NoSuchStateError('Unknown state name or id: ' + state);
    }
  }
  defineGetter(this, 'checkState', _checkState);

  /**
   * function _defineState(stateName: string
   *     [, constantName: string]): undefined
   *     throws TypeError;
   *
   */
  function _defineState(stateName, constantName)
  {
    if (typeof stateName != STRING_STR)
    {
      throw new TypeError('stateName: Expecting ' + STRING_STR);
    }

    if (constantName && typeof constantName !== STRING_STR)
    {
      throw new TypeError('constantName: Expecting ' + STRING_STR);
    }
    else if (!constantName)
    {
      constantName = stateName; // TODO: uppercase transformation etc.
    }

    // TODO: Check if state name conflicts with already defined attributes.

    var i = _stateId.push(stateName) - 1;
    _callbacks.leave.push([]);
    _callbacks.enter.push([]);
    _states[stateName] = i;
    _stateConstants[constantName] = i;
    defineGetter(this, constantName, _states[stateName]);

    // Checking if _currentState is null is due to the idea that it might be
    // set by other means then just by this method.
    if (_currentState == null && i == 0)
    {
      // Set current state to first registered state.
      _currentState = i;
    }
  }
  defineGetter(this, 'defineState', function(stateName, constantName)
  {
    _defineState.call(this, stateName, constantName);

    return this;  // Chaining.
  });

  defineGetter(this, 'maxStateId', undefined, function()
  {
    return _stateId.lenght == 0 ? null : _stateId.length - 1;
  });

  /**
   * _normalizeState(state: number | string, raiseException: bool):
   *     number | null throws TypeError, NoSuchStateError
   */
  function _normalizeState(state, raiseException)
  {
    var result = null;  // Default in case of raiseException

    if (raiseException)
    {
      _checkState(state);
    }
    else if(!_stateExists(state))
    {
      return result;  // Terminate with null on nonexistent state.
    }

    switch (typeof state)
    {
      case NUMBER_STR:
        result = state;
        break;
      case STRING_STR:
        result = _states[state]
        break;
      default:
      {
        if (state.toString && typeof state.toString == FUNCTION_STR)
        {
          result = _states[state.toString()];
        }
        else
        {
          throw new TypeError(STATE_STR + ': Expecting ' + NUMBER_STR + ', '
            + STRING_STR + ' or ' + OBJECT_STR + ' with toString method.');
        }
      }
    }

    return result;
  }
  defineGetter(this, 'normalizeState', _normalizeState);

  /**
   * _getCallbacks(when: string, state: number): array
   */
  function _getCallbacks(when, state)
  {
    var scopedCallbacks = _callbacks[when];

    return (state == undefined ? scopedCallbacks : scopedCallbacks[state]);
  }

  /**
   * _registerCallback(when: string, callback: function[, state: number]):
   *     undefined;
   *
   * Argument state has to be already normalized as string.
   */
  function _registerCallback(when, callback, state)
  {
    _getCallbacks(when, state).push(callback);
  }

  /**
   * function _on([when: string = Controler.ENTER], state: string | number
   *     , callback: function): undefined
   *     throws TypeError, NoSuchStateError
   *
   * function _on(when: string, callback: function): undefined
   *     throws TypeError, NoSuchStateError
   */
  function _on()
  {
    var when = null;
    var state = null;
    var callback = null;
    var normalizedState = null;

    // Populate named arguments.

    if (arguments.length >= 3)
    {
      when = arguments[0];
      state = arguments[1];
      callback = arguments[2];
    }
    else if (arguments.length == 2)
    {
      if (typeof arguments[0] == STRING_STR
        && Controler.whenceExist(arguments[0]))
      {
        when = arguments[0];
      }
      else
      {
        state = arguments[0];
        when = Controler.ENTER;   // Default whence.
      }

      callback = arguments[1];
    }
    else
    {
      throw new Error('on(): Too few arguments passed')
    }

    // Check that the arguments passed to function are consistent.

    Controler.checkWhence(when);  // Throws exception on failure.
    if (state != null)
    {
      // Throws NoSuchStateError:
      normalizedState = _normalizeState(state, true);
    }

    if (typeof callback != FUNCTION_STR)
    {
      throw new TypeError('callback: Expecting ' + FUNCTION_STR + '.');
    }

    var isStateSpecificWhence = Controler.isStateSpecificWhence(when);
    if (normalizedState === null && isStateSpecificWhence)
    {
      throw new Error('whence "' + when
        + '" has to be used with specific state.');
    }
    else if (normalizedState !== null && !isStateSpecificWhence)
    {
      throw new Error('whence "' + when
        + '" can not be used with specific state.');
    }

    // Store callback to a proper place.

    var registerArgs = [when, callback];
    if (isStateSpecificWhence)
    {
      registerArgs.push(normalizedState);
    }
    _registerCallback.apply(this, registerArgs);
  }
  defineGetter(this, 'on', function(when, state, callback) {
    _on(when, state, callback)

    return this;  // Chaining.
  });

  /**
   * _enter(state: number | string[, callbacks: function | object]): undefined
   *     throws TypeError, NoSuchStateError
   */
  function _enter(state, localCallbacks)
  {
    var normalizedState = _normalizeState(state, true);
    var leavingState = _stateId[_currentState];
    var enteringState = _stateId[normalizedState];
    // TODO: Reflexive state transformations should be allowed if user needs
    //       them. Introduce attribute "reflexive"?
    var isStateChange = _currentState != normalizedState;
    var hasFailed = false;

    function invokeCallbacks(when, oldStateChangeEvent)
    {
      var stateChangeEvent = new StateChangeEvent(when, leavingState,
        enteringState, oldStateChangeEvent);

      // Callbacks are executed always in context of _currentState, this
      // means that for when=Controler.ENTER it has to be modified prior
      // to calling this function.
      var scopedCallbacks = _getCallbacks(when,
        Controler.isStateSpecificWhence(when) ? _currentState : undefined);

      for (var i = 0; i < scopedCallbacks.length; i++)
      {
        scopedCallbacks[i].call(this, stateChangeEvent);
      }

      return stateChangeEvent;
    }

    // Registered callbacks aren't executed when not changing the state. It is
    // possible to detect this situation in success callback passed to this
    // method.
    if (isStateChange)
    {
      // Leave event handlers may also prevent entering different state.
      var evt = invokeCallbacks(Controler.LEAVE);

      hasFailed = evt.hasFailed;
      if (!hasFailed)
      {
        evt = invokeCallbacks(Controler.PRE_ENTER, evt);
        _currentState = normalizedState;
        evt = invokeCallbacks(Controler.ENTER, evt);
        invokeCallbacks(Controler.POST_ENTER, evt);
      }
    }

    function runCallback(callbacks)
    {
      var callback = callbacks[hasFailed ? FAILURE_STR : SUCCESS_STR];

      if (typeof callback == FUNCTION_STR)
      {
        var callbackArguments = [leavingState, enteringState];

        if (hasFailed)
        {
          callbackArguments.push(isStateChange);
        }

        callback.apply(this, callbackArguments);
      }
    }

    // Callback is executed always, if present, even if state transformation is
    // not allowed. Global callbacks are used when they aren't shadowed by
    // local callback(s), i.e. that/those passed as an argument to this
    // function.
    var availableCallbacks = {};
    // It is neccessary to have a copy so we can do shadowing.
    for (var callbackType in _globalCallbacks)
    {
      availableCallbacks[callbackType] = _globalCallbacks[callbackType];
    }
    if (localCallbacks)
    {
      if (typeof localCallbacks == FUNCTION_STR)
      {
        // In this case only calback that should be executed on success was
        // passed and therefore we aren't going to call it.
        availableCallbacks[SUCCESS_STR] = localCallbacks;
      }
      else
      {
        for (var callbackType in availableCallbacks)
        {
          if (localCallbacks.hasOwnProperty(callbackType)
            && typeof localCallbacks[callbackType] == FUNCTION_STR)
          {
            availableCallbacks[callbackType] = localCallbacks[callbackType];
          }
        }
      }
    }
    runCallback.call(this, availableCallbacks);
  }
  defineGetter(this, 'enter', function(state, callbacks) {
    _enter(state, callbacks);

    return this;  // Chaining.
  });

  withToJson(this, function() {
    var obj =
      { currentState: _currentState
      , states: []
      };

    for (var i = 0; i < _stateId.length; i++)
    {
      obj.states.push({name: _stateId[i], constant: undefined});
    }

    for (var key in _stateConstants)
    {
      obj.states[_stateConstants[key]].constant = key;
    }

    return JSON.stringify(obj);
  });

  if (description && description.states && description.states.length)
  {
    for (var i = 0; i < states.length; i++)
    {
      _defineState(states[i].name, states[i].constant);
    }
  }
}

/**
 * function constructControlerClass(cls: Function): Function
 */
function constructControlerClass(cls)
{
  var _const =
    { LEAVE: 'leave'
    , PRE_ENTER: 'preEnter'
    , ENTER: 'enter'
    , POST_ENTER: 'postEnter'
    };

  for (var key in _const)
  {
    defineGetter(cls, key, _const[key]);
  }

  function _whenceExist(when)
  {
    for (var key in _const)
    {
      if (_const[key] === when)
      {
        return true;
      }
    }

    return false;
  }
  defineGetter(cls, 'whenceExist', _whenceExist);

  defineGetter(cls, 'checkWhence', function(when)
  {
    if (!_whenceExist(when))
    {
      throw new Error('No such whence.');
    }
  });

  defineGetter(cls, 'isStateSpecificWhence', function(when)
  {
    var ret = null;

    switch (when)
    {
      case _const.LEAVE:      // Pass through.
      case _const.ENTER:
        ret = true;
        break;
      case _const.PRE_ENTER:  // Pass through.
      case _const.POST_ENTER:
        ret = false;
        break;
      default:
        // TODO
        break;
    }

    return ret;
  });

  return cls;
}

constructControlerClass(Controler);
namespace.Controler = withExtend(constructControlerClass, Controler);
})(window.trskop = window.trskop || {}, window);

// vim:ts=2 sw=2 expandtab
