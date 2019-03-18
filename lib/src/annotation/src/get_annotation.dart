import 'dart:mirrors';

List<T> getAnnotations<T>(DeclarationMirror declaration) {
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
