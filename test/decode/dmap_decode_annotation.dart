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
			var job = decode<User>({"last_name": "doe", "first_name": "john"});
			expect(job.lastName, "doe");
			expect(job.firstName, "john");
		});
	});
	group("multiple annotation", () {
		test("basic test", () {
			var user = decode<User>({"last_name": "doe", "first_name": "john"});
			expect(user.lastName, "doe");
			expect(user.firstName, "john");
			var dec = new Decoder(tagName: 'alias');
			var user2 = dec.decode<User>({"name": "name1", "first": "first1"});
			expect(user2.lastName, "name1");
			expect(user2.firstName, "first1");
		});
	});
}
