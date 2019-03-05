import './decode_base.dart';

/// [defaultDecoder] is a global object used on [decode] and [decodeIn] global functions
var defaultDecoder = new Decoder(zeroFields: true);

/// [decode] will decode the [input] and returned a new object of type [T] with field mapped
T decode<T>(Map<String, dynamic> input) {
	return defaultDecoder.decode<T>(input);
}


/// [decode] will decode the [input] into [receiver]
void decodeIn<T>(Map<String, dynamic> input, T receiver) {
	defaultDecoder.decodeIn<T>(input, receiver);
}
