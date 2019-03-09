import 'dart:mirrors';

import '../../annotation.dart';

const _defaultTypes = <Type>[bool, int, double, String, Runes];
var _baseZeroValues = <Type, dynamic>{
  int: 0,
  double: 0.0,
  String: "",
  Runes: Runes(""),
  bool: false,
};

/// Decoder define the configuration which will decode an dynamic object into a object
class Decoder {
  Decoder({this.tagName = "dmap", this.errorUnused = false, this.zeroFields = false, this.errorUnknown = false});
  
  /// [tagName] will define the name of the tag which will be used when decoding
  String tagName;

  /// [errorUnused] will throw an [UnusedException] when an field is not used at the end.
  bool errorUnused;

  /// [errorUnknown] will throw an UnknownFieldException when a field from the source can't be set in the destination
  bool errorUnknown;

  /// [zeroFields] will instantiate zero values of the object when seen.
  bool zeroFields;

  /// [maxDepth] will define the maximum recursion  which can occurs on a decoding.
  int maxDepth;
  
  Map<Type, dynamic> _zeroValues = Map.from(_baseZeroValues);
  
  void registerZeroValues(Type type, dynamic value) => _zeroValues[type] = value;

  T decode<T>(Map<String, dynamic> input) {
    var r = reflectType(T);
    return _decode<T>(input, r.reflectedType, typeArgument: r.typeArguments);
  }

  void decodeIn<T>(Map<String, dynamic> input, T receiver) {
    var reflectee = reflectType(T);
    _decodeIn<T>(input, receiver, typeArgument: reflectee.typeArguments);
  }

  T _decode<T>(Map<String, dynamic> input, Type type, {List<TypeMirror> typeArgument = const []}) {
    if (type == dynamic) {
      return input as T;
    }
    var receiver = zeroValueOfType(type);
    return _decodeIn<T>(input, receiver, typeArgument: typeArgument);
  }

  T _decodeIn<T>(Map<String, dynamic> input, T receiver, {List<TypeMirror> typeArgument = const []}) {
    if (input == null) {
      return receiver;
    }
    if (receiver is Map) {
      input.forEach((k, v) {
        receiver[k] = _decode(v, typeArgument[1].reflectedType);
      });
      return receiver;
    }
    var reflectee = reflect(receiver);
    reflectee.type.instanceMembers.forEach((key, value) {
      this._symbolLogic(input, reflectee, key, value);
    });
    return receiver;
  }

  // _symbolLogic will filter the symbol of class and retrieve the corresponding entry in the input
  _symbolLogic(Map<String, dynamic> input, InstanceMirror reflectee, Symbol symbol, MethodMirror methodMirror) {
    print(methodMirror.simpleName.toString());
    print(methodMirror.metadata);
    print(getAnnotation<Tag>(methodMirror));
    if (!methodMirror.isSetter) {
      return;
    }
    var name = this._sanitizeName(symbol);
    if (!input.containsKey(name)) {
      if (zeroFields) {
        _apply(reflectee, Symbol(name), zeroValueOfType(methodMirror.returnType.reflectedType));
      }
      return;
    }
    try {
      if (_defaultTypes.contains(methodMirror.returnType.reflectedType)) {
        _apply(reflectee, Symbol(name), input[name]);
      } else {
        var field = reflectee.getField(Symbol(name));
        var rType = methodMirror.returnType;
        var val;
        if (field.reflectee == null) {
          val = zeroValueOfType(rType.reflectedType);
        } else {
          val = field.reflectee;
        }
        if (rType.isSubtypeOf(reflectType(List))) {
          (input[name] as Iterable).forEach((e) {
            (val as List).add(_decode(input, rType.typeArguments.first.reflectedType));
          });
          _apply(reflectee, Symbol(name), val);
        } else {
          _apply(reflectee, Symbol(name), this._decodeIn(input[name], val));
        }
      }
    } on NoSuchMethodError {
      if (this.errorUnused) {
        rethrow;
      }
    }
  }

  _apply(InstanceMirror instance, Symbol key, dynamic val) {
    if (zeroFields) {
      val = zeroValue(val);
    }
    instance.setField(key, val);
  }

  String _sanitizeName(Symbol s) {
    var name = MirrorSystem.getName(s);
    name = name.substring(0, name.length - 1);
    return name;
  }
}

T getAnnotation<T>(DeclarationMirror declaration) {
  for (var instance in declaration.metadata) {
    if (instance.hasReflectee) {
      var reflectee = instance.reflectee;
      if (reflectee.runtimeType == T) {
        return reflectee;
      }
    }
  }
  
  return null;
}

dynamic zeroValue(dynamic val) {
  if (val != null) {
    return val;
  }
  var r = reflectClass(val);
  return r.newInstance(Symbol(""), []).reflectee;
}

dynamic zeroValueOfType(Type val) {
  if (_baseZeroValues.containsKey(val)) {
    return _baseZeroValues[val];
  }
  var t = reflectType(val);
  if (t is ClassMirror) {
    return t.newInstance(Symbol(""), []).reflectee;
  }
}

class InvalidType implements Exception {}

/// [UnusedException] is an exception thrown when [Decoder.errorUnused] is activated and a key remain unused.
class UnusedException implements Exception {
  UnusedException(this.key, [this.message]);

  String message;
  String key;

  String toString() => "$key is unused";
}
