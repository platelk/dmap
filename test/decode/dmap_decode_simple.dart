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
			var user = dmap.decode<User>({});
			expect(user.admin, isFalse);
		});
		test("true", () {
			var user = dmap.decode<User>({"admin": true});
			expect(user.admin, isTrue);
		});
		test("false", () {
			var user = dmap.decode<User>({"admin": false});
			expect(user.admin, isFalse);
		});
	});
	group('int', () {
		test("default value", () {
			var user = dmap.decode<User>({});
			expect(user.age, 0);
		});
		test("0", () {
			var user = dmap.decode<User>({"age": 0});
			expect(user.age, 0);
		});
		test("value", () {
			var user = dmap.decode<User>({"age": 42});
			expect(user.age, 42);
		});
	});
	group('double', () {
		test("default value", () {
			var user = dmap.decode<User>({});
			expect(user.money, 0.0);
		});
		test("0", () {
			var user = dmap.decode<User>({"money": 0.0});
			expect(user.money, 0.0);
		});
		test("value", () {
			var user = dmap.decode<User>({"money": 42.0});
			expect(user.money, 42.0);
		});
	});
	group('String', () {
		test("default value", () {
			var user = dmap.decode<User>({});
			expect(user.name, "");
		});
		test("empty string", () {
			var user = dmap.decode<User>({"name": ""});
			expect(user.name, "");
		});
		test("value", () {
			var user = dmap.decode<User>({"name": "john"});
			expect(user.name, "john");
		});
	});
}
