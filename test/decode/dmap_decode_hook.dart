import 'package:dmap/dmap.dart';
import 'package:test/test.dart';

class User {
	String lastName;
	String firstName;
	int age;
	DateTime creationTime;
}

void main() {
	group("decode hook", () {
		test("string to int", () {
			var decoder = new Decoder(hook: (fromType, toType, data) {
				if (fromType == String && toType == int) {
					return int.parse(data);
				}
				return data;
			});
			var user = decoder.decode<User>({"lastName": "doe", "firstName": "john", "age": "42"});
			expect(user.lastName, "doe");
			expect(user.firstName, "john");
			expect(user.age, 42);
		});
		test("string to time", () {
			var decoder = new Decoder(hook: (fromType, toType, data) {
				if (fromType == String && toType == DateTime) {
					return DateTime.parse(data);
				}
				if (fromType == String && toType == int) {
					return int.parse(data);
				}
				return data;
			});
			var user = decoder.decode<User>({"lastName": "doe", "firstName": "john", "age": 42, "creationTime": "2012-02-27 13:27:00"});
			expect(user.lastName, "doe");
			expect(user.firstName, "john");
			expect(user.age, 42);
			expect(user.creationTime.year, 2012);
		});
	});
}
