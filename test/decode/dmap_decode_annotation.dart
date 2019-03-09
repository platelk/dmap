import 'package:dmap/dmap.dart';
import 'package:test/test.dart';

class User {
	@Tag(name: "last_name")
	String lastName;
	@Tag(name: "first_name")
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
			var job = decode<Job>({"title": "dev", "user": {"last_name": "doe", "first_name": "john"}});
			expect(job.title, equals("dev"));
			expect(job.user, isNotNull);
			expect(job.user.lastName, "doe");
			expect(job.user.firstName, "john");
		});
		test("null nested object", () {
			var job = decode<Job>({"title": "dev", "user": null});
			expect(job.title, equals("dev"));
			expect(job.user, isNotNull);
		});
	});
}
