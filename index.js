// Generated by CoffeeScript 2.3.1
  /** @license MIT (c) 2018 Laurent Payot  */
  /* type helpers */
var AnyType, Tuple, TypedMap, TypedObject, TypedSet, _Etc, _Tuple, _TypedMap, _TypedObject, _TypedSet, badPath, error, etc, fn, isAnyType, isType, maybe, promised, shouldBe, typeName, typeOf,
  splice = [].splice;

// trows customized error
error = function(msg) {
  throw new Error((function() {
    switch (msg[0]) {
      case '!':
        return `Invalid type syntax: ${msg.slice(1)}`;
      case '@':
        return `Invalid signature: ${msg.slice(1)}`;
      default:
        return `Type error: ${msg}`;
    }
  })());
};

/* typed classes */
_Tuple = class _Tuple {
  constructor(...types1) {
    this.types = types1;
    if (arguments.length < 2) {
      error("!Tuple must have at least two type arguments.");
    }
    if (this.types.every(function(t) {
      return isAnyType(t); // return needed
    })) {
      return Array;
    }
  }

};

_TypedObject = class _TypedObject {
  constructor(type1) {
    this.type = type1;
    if (arguments.length !== 1) {
      error("!TypedObject must have exactly one type argument.");
    }
    if (isAnyType(this.type)) { // return needed
      return Object;
    }
  }

};

_TypedSet = class _TypedSet {
  constructor(type1) {
    this.type = type1;
    if (arguments.length !== 1) {
      error("!TypedSet must have exactly one type argument.");
    }
    if (isAnyType(this.type)) { // return needed
      return Set;
    }
  }

};

_TypedMap = (function() {
  class _TypedMap {
    constructor(t1, t2) {
      switch (arguments.length) {
        case 0:
          error("!TypedMap must have at least one type argument.");
          break;
        case 1:
          if (isAnyType(t1)) {
            return Map;
          } else {
            this.valuesType = t1; // return needed
          }
          break;
        case 2:
          if (isAnyType(t1) && isAnyType(t2)) {
            return Map;
          } else {
            [this.keysType, this.valuesType] = [
              t1,
              t2 // return needed
            ];
          }
          break;
        default:
          error("!TypedMap can not have more than two type arguments.");
      }
    }

  };

  _TypedMap.prototype.keysType = [];

  _TypedMap.prototype.valuesType = [];

  return _TypedMap;

}).call(this);

_Etc = class _Etc { // typed rest arguments list
  constructor(type1 = []) {
    this.type = type1;
    if (arguments.length > 1) {
      error("!'etc' can not have more than one type argument.");
    }
  }

};

// not exported
isAnyType = function(o) {
  return o === AnyType || Array.isArray(o) && o.length === 0;
};

AnyType = function() {
  if (arguments.length) {
    return error("!'AnyType' can not have a type argument.");
  } else {
    return [];
  }
};

maybe = function(...types) {
  if (!arguments.length) {
    error("!'maybe' must have at least one type argument.");
  }
  if (types.some(function(t) {
    return isAnyType(t);
  })) {
    return [];
  } else {
    return [void 0, null].concat(types);
  }
};

promised = function(type) {
  if (arguments.length !== 1) {
    error("!'promised' must have exactly one type argument.");
  }
  if (isAnyType(type)) {
    return Promise;
  } else {
    return Promise.resolve(type);
  }
};

Tuple = function(...args) {
  return new _Tuple(...args);
};

TypedObject = function(...args) {
  return new _TypedObject(...args);
};

TypedSet = function(...args) {
  return new _TypedSet(...args);
};

TypedMap = function(...args) {
  return new _TypedMap(...args);
};

etc = function(...args) {
  return new _Etc(...args);
};

// typeOf([]) is 'Array', whereas typeof [] is 'object'. Same for null, Promise etc.
typeOf = function(val) {
  if (val === void 0 || val === null) {
    return '' + val;
  } else {
    return val.constructor.name;
  }
};

// check that a value is of a given type or of any (undefined) type, e.g.: isType("foo", String)
isType = function(val, type) {
  var k, keys, keysType, prefix, ref, ref1, t, types, v, values, valuesType;
  if (Array.isArray(type)) { // NB: special Array case http://web.mit.edu/jwalden/www/isArray.html
    switch (type.length) {
      case 0:
        return true; // any type: `[]`
      case 1: // typed array type, e.g.: `Array(String)`
        if (!Array.isArray(val)) {
          return false;
        }
        if (isAnyType(type[0])) {
          return true;
        }
        return val.every(function(e) {
          return isType(e, type[0]);
        });
      default:
        return type.some(function(t) {
          return isType(val, t); // union of types, e.g.: `[Object, null]`
        });
    }
  } else {
    switch (type != null ? type.constructor : void 0) {
      case void 0:
      case String:
      case Number:
      case Boolean:
        return val === type; // literal type or undefined or null
      case Function:
        switch (type) {
          // type helpers used directly as functions
          case AnyType:
            return true;
          case promised:
          case maybe:
          case TypedObject:
          case TypedSet:
          case TypedMap:
            return error(`!'${type.name}' can not be used directly as a function.`);
          case etc:
            return error("!'etc' can not be used in types.");
          default:
            // constructors of native types (Number, String, Object, Array, Promise, Set, Map…) and custom classes
            return (val != null ? val.constructor : void 0) === type;
        }
        break;
      case Object: // Object type, e.g.: `{id: Number, name: {firstName: String, lastName: String}}`
        if ((val != null ? val.constructor : void 0) !== Object) {
          return false;
        }
        for (k in type) {
          v = type[k];
          if (!isType(val[k], v)) {
            return false;
          }
        }
        return true;
      case _Tuple:
        types = type.types;
        if (!(Array.isArray(val) && val.length === types.length)) {
          return false;
        }
        return val.every(function(e, i) {
          return isType(e, types[i]);
        });
      case _TypedObject:
        if ((val != null ? val.constructor : void 0) !== Object) {
          return false;
        }
        t = type.type;
        if (isAnyType(t)) {
          return true;
        }
        return Object.values(val).every(function(v) {
          return isType(v, t);
        });
      case _TypedSet:
        if ((val != null ? val.constructor : void 0) !== Set) {
          return false;
        }
        t = type.type;
        if (isAnyType(t)) {
          return true;
        }
        if ((ref = t != null ? t.constructor : void 0) === (void 0) || ref === String || ref === Number || ref === Boolean) {
          error(`!Typed Set type can not be a literal of type '${t}'.`);
        }
        return [...val].every(function(e) {
          return isType(e, t);
        });
      case _TypedMap:
        if ((val != null ? val.constructor : void 0) !== Map) {
          return false;
        }
        ({keysType, valuesType} = type);
        switch (false) {
          case !(isAnyType(keysType) && isAnyType(valuesType)):
            return true;
          case !isAnyType(keysType):
            return Array.from(val.values()).every(function(e) {
              return isType(e, valuesType);
            });
          case !isAnyType(valuesType):
            return Array.from(val.keys()).every(function(e) {
              return isType(e, keysType);
            });
          default:
            keys = Array.from(val.keys());
            values = Array.from(val.values());
            return keys.every(function(e) {
              return isType(e, keysType);
            }) && values.every(function(e) {
              return isType(e, valuesType);
            });
        }
        break;
      case _Etc:
        return error("!'etc' can not be used in types.");
      default:
        prefix = (ref1 = type.constructor) === Set || ref1 === Map ? 'the provided Typed' : '';
        return error(`!Type can not be an instance of ${typeOf(type)}. Use ${prefix}${typeOf(type)} as type instead.`);
    }
  }
};

// returns a list of keys path to where the type do not match + value not maching + type not matching
badPath = function(obj, typeObj) {
  var k, ref, t;
  for (k in typeObj) {
    t = typeObj[k];
    if (!isType(obj[k], t)) {
      return [k].concat(((ref = obj[k]) != null ? ref.constructor : void 0) === Object ? badPath(obj[k], typeObj[k]) : [obj[k], typeObj[k]]);
    }
  }
};

// returns the type name for signature error messages (supposing type is always correct)
typeName = function(type) {
  var t;
  if (isAnyType(type)) {
    return "any type";
  } else {
    switch (type != null ? type.constructor : void 0) {
      case void 0:
        return typeOf(type);
      case Array:
        if (type.length === 1) {
          return `array of '${typeName(type[0])}'`;
        } else {
          return ((function() {
            var l, len, results;
            results = [];
            for (l = 0, len = type.length; l < len; l++) {
              t = type[l];
              results.push(typeName(t));
            }
            return results;
          })()).join(" or ");
        }
        break;
      case Function:
        return type.name;
      case Object:
        return "custom type object";
      case _Tuple:
        return `tuple of ${type.types.length} elements '${((function() {
          var l, len, ref, results;
          ref = type.types;
          results = [];
          for (l = 0, len = ref.length; l < len; l++) {
            t = ref[l];
            results.push(typeName(t));
          }
          return results;
        })()).join(", ")}'`;
      default:
        return `literal ${typeOf(type)} '${type}'`;
    }
  }
};

// type error message comparison part helper
shouldBe = function(val, type) {
  var bp, bt, bv, ref;
  if ((val != null ? val.constructor : void 0) === Object) {
    ref = badPath(val, type), [...bp] = ref, [bv, bt] = splice.call(bp, -2);
    return `should be an object with key '${bp.join('.')}' of type ${typeName(bt)} instead of ${typeOf(bv)}`;
  } else {
    return `(${val}) should be of type ${typeName(type)} instead of ${typeOf(val)}`;
  }
};

// wraps a function to check its arguments types and result type
fn = function(argTypes, resType, f) {
  if (!Array.isArray(argTypes)) {
    error("@Array of arguments types is missing.");
  }
  if ((resType != null ? resType.constructor : void 0) === Function && !resType.name) {
    error("@Result type is missing.");
  }
  if ((f != null ? f.constructor : void 0) !== Function) {
    error("@Function to wrap is missing.");
  }
  return function(...args) { // returns an unfortunately anonymous function
    var arg, i, j, l, len, len1, m, ref, rest, result, t, type;
    rest = false;
    for (i = l = 0, len = argTypes.length; l < len; i = ++l) {
      type = argTypes[i];
      if (type === etc || (type != null ? type.constructor : void 0) === _Etc) { // rest type
        if (i + 1 < argTypes.length) {
          error("@Rest type must be the last of the arguments types.");
        }
        rest = true;
        t = type === etc ? [] : type.type;
        if (!isAnyType(t)) { // no checks if rest type is any type
          ref = args.slice(i);
          for (j = m = 0, len1 = ref.length; m < len1; j = ++m) {
            arg = ref[j];
            if (!isType(arg, t)) {
              error(`Argument number ${i + j + 1} ${shouldBe(arg, t)}.`);
            }
          }
        }
      } else {
        if (!isAnyType(type)) { // not checking type if type is any type
          if (args[i] === void 0) {
            if (!isType(void 0, type)) {
              error(`Missing required argument number ${i + 1}.`);
            }
          } else {
            if (!isType(args[i], type)) {
              error(`Argument number ${i + 1} ${shouldBe(args[i], type)}.`);
            }
          }
        }
      }
    }
    if (args.length > argTypes.length && !rest) {
      error("Too many arguments provided.");
    }
    if ((resType != null ? resType.constructor : void 0) === Promise) {
      // NB: not using `await` because CS would transpile the returned function as an async one
      return resType.then(function(promiseType) {
        var promise;
        promise = f(...args);
        if ((promise != null ? promise.constructor : void 0) !== Promise) {
          error("Function should return a promise.");
        }
        return promise.then(function(result) {
          if (!isType(result, promiseType)) {
            error(`Promise result ${shouldBe(result, promiseType)}.`);
          }
          return result;
        });
      });
    } else {
      result = f(...args);
      if (!isType(result, resType)) {
        error(`Result ${shouldBe(result, resType)}.`);
      }
      return result;
    }
  };
};

module.exports = {typeOf, isType, fn, maybe, AnyType, promised, etc, Tuple, TypedObject, TypedSet, TypedMap};
