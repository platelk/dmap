import './encode_base.dart';

/// [defaultEncoder] is a global object used on [encode] and [encodeIn] global functions
var defaultEncoder = Encoder();

/// [encode] will encode the [input] and returned a new object of type [T] with field mapped
Map<String, dynamic> encode<T>(T input) {
  return defaultEncoder.encode<T>(input);
}
