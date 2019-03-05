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
      var job = decode<Job>({"title": "dev", "user": {"lastName": "doe", "firstName": "john"}});
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
