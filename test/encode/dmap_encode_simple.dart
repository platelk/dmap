import 'package:dmap/dmap.dart' as dmap;
import 'package:test/test.dart';

class User {
	String name;
	int age;
	bool admin;
	double money;
}

void main() {
	group('bool', () {
		test("default value", () {
			var user = new User()
			..admin = false;
			var res = dmap.encode(user);
			expect(res["admin"], isFalse);
		});
	});
	group('string', () {
		test("default value", () {
			var user = new User()
				..name = "john";
			var res = dmap.encode(user);
			expect(res["name"], "john");
		});
	});
	group('double', () {
		test("default value", () {
			var user = new User()
				..money = 42.5;
			var res = dmap.encode(user);
			expect(res["money"], 42.5);
		});
	});
	group('int', () {
		test("default value", () {
			var user = new User()
				..age = 42;
			var res = dmap.encode(user);
			expect(res["age"], 42);
		});
	});
}
