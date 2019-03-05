# Dmap

*dmap* is a simple library inspired by [mapstructure]() based on [mirrors] to allow simple (and not necessarly 
efficient) mapping of a *Map<String, dynamic>* into a object or class

## Usage

```dart
import "package:dmap/dmap.dart";

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
	var job = decode<Job>({"title": "dev", "user": {"lastName": "doe", "firstName": "john"}});
	print(job.user.lastName); // "doe"
}
```

## FAQ

* **Why using mirros ?** This library is oriented to be simple to use and mirrors allow a dynamisme which can offers 
nice things
* **On which plateform can it be used ?** only on [server]() and [flutter]()

## Authors

* [PLATEL Kevin]()
