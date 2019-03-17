import 'package:dmap/dmap.dart';
import 'package:test/test.dart';

class User {
	String lastName;
	String firstName;
	int age;
}

class Job {
	User user;
	String title;
}

void main() {
	group("netsted object", () {
		test("with nested object", () {
			var user = new User()
				..firstName = "john"
				..lastName = "doe"
				..age = 42
			;
			var job = new Job()
			..user = user
			..title = "dev"
			;
			var res = encode<Job>(job);
			expect(res["title"], equals("dev"));
			expect(res["user"], isNotNull);
			expect(res["user"]["firstName"], "john");
			expect(res["user"]["lastName"], "doe");
		});
	});
}
