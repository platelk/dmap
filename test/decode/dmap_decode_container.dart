import 'package:dmap/dmap.dart';
import 'package:test/test.dart';

class User {
  String lastName;
  String firstName;
  int age;
}

class Group {
  List<User> users;
  String name;
}

class DynamicList {
  List<dynamic> users;
}

void main() {
  group("list", () {
    test('list of object', () {
      var group = decode<Group>({"name": "test", "users": [{"lastName": "user3"}]});
      expect(group.name, "test");
      expect(group.users.length, equals(1));
    });
    test('zero value list', () {
      var group = decode<Group>({"name": "test"});
      expect(group.name, "test");
      expect(group.users, isNotNull);
      expect(group.users.length, equals(0));
    });
    test('dynamic list', () {
      var group = decode<DynamicList>({"users": [{"lastName": "user3"}]});
      expect(group.users, isNotNull);
      expect(group.users.length, equals(1));
    });
  });
  group("map", () {
    test('map of object', () {
      var group = decode<Map<String, User>>({"user1": {"lastName": "toto"}, "user2": {"lastName": "tata"}});
      expect(group.length, equals(2));
      expect(group["user1"], isNotNull);
      expect(group["user2"], isNotNull);
      expect(group["user2"].lastName, equals("tata"));
    });
  });
}
