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

/// [DecodeHook] is a function prototype which is called to
typedef DecodeHook<R> = R Function(Type from, Type to, dynamic data);

/// Decoder define the configuration which will decode an dynamic object into a object
class Decoder {
  Decoder(
      {this.tagName = "dmap",
      this.errorUnused = false,
      this.zeroFields = false,
      this.errorUnknown = false,
      this.hook});

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

  /// [_zeroValues] contains default zero values for specified types
  Map<Type, dynamic> _zeroValues = Map.from(_baseZeroValues);

  DecodeHook hook;

  /// [registerZeroValues] allow external registration of default zero values
  void registerZeroValues(Type type, dynamic value) =>
      _zeroValues[type] = value;

  /// [decode] will return a new object of type [T] with its attributes mapped from [input]
  T decode<T>(Map<String, dynamic> input) {
    var r = reflectType(T);
    return _decode<T>(input, r.reflectedType, typeArgument: r.typeArguments);
  }

  /// [decodeIn] will decode the input and map its values to [receiver]
  void decodeIn<T>(Map<String, dynamic> input, T receiver) {
    var reflectee = reflectType(T);
    _decodeIn<T>(input, receiver, typeArgument: reflectee.typeArguments);
  }

  // [_decode] will manage instantiation of the receiving variable and call _decodeIn
  T _decode<T>(Map<String, dynamic> input, Type type,
      {List<TypeMirror> typeArgument = const []}) {
    if (type == dynamic) {
      return input as T;
    }
    var receiver = _zeroValueOfType(type);
    return _decodeIn<T>(input, receiver, typeArgument: typeArgument);
  }

  // [_decodeIn] will iterate on each attributes of the receiver and call [_symbolLogic] to apply value\
  // It will also have special case for Map<K, V> receiver.
  T _decodeIn<T>(Map<String, dynamic> input, T receiver,
      {List<TypeMirror> typeArgument = const []}) {
    if (input == null) {
      return receiver;
    }
    // Check if receiver is a map, if it is, we need to pass values and take typeArguments
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
  _symbolLogic(Map<String, dynamic> input, InstanceMirror reflectee,
      Symbol symbol, MethodMirror methodMirror) {
    if (!methodMirror.isSetter) {
      return;
    }
    var decl = reflectee.type.declarations;
    var targetName = this._sanitizeName(symbol);
    var fromName = this._getFromName(
        _getAnnotations<Tag>(decl[Symbol(targetName)]), targetName);
    var targetType = methodMirror.returnType;
    if (!input.containsKey(fromName)) {
      if (zeroFields) {
        _apply(reflectee, Symbol(targetName),
            _zeroValueOfType(targetType.reflectedType));
      }
      return;
    }
    try {
      var inputValue = input[fromName];
      if (this.hook != null) {
        inputValue = this.hook(
            inputValue?.runtimeType, targetType.reflectedType, input[fromName]);
      }
      if (_defaultTypes.contains(targetType.reflectedType)) {
        _apply(reflectee, Symbol(targetName), inputValue);
      } else if (targetType.isSubtypeOf(reflectType(inputValue.runtimeType))) {
        _apply(reflectee, Symbol(targetName), inputValue);
      } else {
        var field = reflectee.getField(Symbol(targetName));
        var rType = targetType;
        var val;
        if (field.reflectee == null) {
          val = _zeroValueOfType(rType.reflectedType);
        } else {
          val = field.reflectee;
        }
        if (rType.isSubtypeOf(reflectType(List))) {
          (inputValue as Iterable).forEach((e) {
            (val as List)
                .add(_decode(e, rType.typeArguments.first.reflectedType));
          });
          _apply(reflectee, Symbol(targetName), val);
        } else {
          _apply(
              reflectee, Symbol(targetName), this._decodeIn(inputValue, val));
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
      val ??= _zeroValueOfType(instance.type.reflectedType);
    }
    instance.setField(key, val);
  }

  String _sanitizeName(Symbol s) {
    var name = MirrorSystem.getName(s);
    name = name.substring(0, name.length - 1);
    return name;
  }

  String _getFromName(List<Tag> tag, String targetName) {
    for (var value in tag) {
      if (value.tag == this.tagName) {
        return value.name;
      }
    }
    return targetName;
  }
}

List<T> _getAnnotations<T>(DeclarationMirror declaration) {
  var res = <T>[];
  for (var instance in declaration.metadata) {
    if (instance.hasReflectee) {
      var reflectee = instance.reflectee;
      if (reflectee.runtimeType == T) {
        res.add(reflectee);
      }
    }
  }

  return res;
}

dynamic _zeroValueOfType(Type val) {
  if (_baseZeroValues.containsKey(val)) {
    return _baseZeroValues[val];
  }
  var t = reflectType(val);
  if (t is ClassMirror) {
    return t.newInstance(Symbol(""), []).reflectee;
  }
}

/// [InvalidType] is returned if the type of attribute can't be mapped from the input
class InvalidType implements Exception {}

/// [UnusedException] is an exception thrown when [Decoder.errorUnused] is activated and a key remain unused.
class UnusedException implements Exception {
  UnusedException(this.key, [this.message]);

  String message;
  String key;

  String toString() => "$key is unused";
}
