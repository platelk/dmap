import 'package:dmap/dmap.dart';
import 'package:test/test.dart';

class User {
	@Tag(tag: "alias", name: "name")
	@Tag(name: "last_name")
	String lastName;
	@Tag(tag: "alias", name: "first")
	@Tag(name: "first_name")
	String firstName;
	int age;
}

void main() {
	group("simple annotation", () {
		test("basic test", () {
			var user = new User()
				..lastName = "doe"
			..firstName = "john";
			var res = encode<User>(user);
			expect(res["last_name"], "doe");
			expect(res["first_name"], "john");
		});
	});
	group("multiple annotation", () {
		test("basic test", () {
			var user = new User()
				..lastName = "doe"
				..firstName = "john";
			var dec = new Encoder(tagName: 'alias');
			var res = dec.encode<User>(user);
			expect(res["name"], "doe");
			expect(res["first"], "john");
		});
	});
}
