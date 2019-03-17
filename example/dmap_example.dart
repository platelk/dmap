import 'package:dmap/dmap.dart';

class User {
	@Tag(name: "creation_date")
	DateTime creationDate;
	
	@Tag(name: "last_name")
	String lastName;
	
	@Tag(name: "first_name")
	String firstName;
	
	int age;
	
	String toString() => "[$creationDate | $lastName | $firstName | $age]";
}

main() {
	var decoder = new Decoder(hook: (fromType, toType, val) {
		if (fromType == String && toType == DateTime) {
			return DateTime.parse(val);
		}
		return val;
	});
	var input = {
		"creation_date": "2019-03-17",
		"last_name": "Doe",
		"first_name": "John",
		"age": 42
	};
	var output = decoder.decode<User>(input);
	print(output); // [2019-03-17 00:00:00.000 | Doe | John | 42]
}
