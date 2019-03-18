import 'dart:mirrors';

import 'package:dmap/src/annotation/annotation.dart';


const _defaultTypes = <Type>[bool, int, double, String, Runes];

/// [EncodeHook] is a function prototype which is called to
typedef EncodeHook<R> = R Function(Type from, Type to, dynamic data);

/// Encoder define the configuration which will encode an dynamic object into a object
class Encoder {
	Encoder({this.tagName = "dmap",
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
	
	EncodeHook hook;
	
	/// [encode] will return a new object of type [T] with its attributes mapped from [input]
	Map<String, dynamic> encode<T>(T data) {
		return _encodeIn<T>(data);
	}
	
	Map<String, dynamic> _encodeIn<T>(T receiver,
	                                  {List<TypeMirror> typeArgument = const []}) {
		var output = new Map<String, dynamic>();
		// Check if receiver is a map, if it is, we need to pass values and take typeArguments
		if (receiver is Map) {
			return null;
		}
		var reflectee = reflect(receiver);
		reflectee.type.instanceMembers.forEach((key, value) {
			this._symbolLogic(output, reflectee, key, value);
		});
		return output;
	}
	
	// _symbolLogic will filter the symbol of class and retrieve the corresponding entry in the input
	_symbolLogic(Map<String, dynamic> output, InstanceMirror reflectee,
	             Symbol symbol, MethodMirror methodMirror) {
		if (!methodMirror.isSetter) {
			return;
		}
		var decl = reflectee.type.declarations;
		var targetName = this._sanitizeName(symbol);
		var fromName = this._getFromName(
				getAnnotations<Tag>(decl[Symbol(targetName)]), targetName);
		var input = reflectee.getField(Symbol(targetName)).reflectee;
		if (_defaultTypes.contains(input.runtimeType)) {
			output[fromName] = input;
		} else {
			output[fromName] = this._encodeIn(input);
		}
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
