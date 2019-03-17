# Dmap

*dmap* is a simple library inspired by [mapstructure]() based on [mirrors] to allow simple (and not necessarly 
efficient) mapping of a *Map<String, dynamic>* into a object or class

## Feature

* Decode `Map<String, dynamic>` into `Class`
* Zero values handling to avoid null in nested fields
* Hooks to transform types on parsing
* Allow renaming
* Allow multiple binding of an object through multiple tags

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

With hooks 

```dart
import 'package:dmap/dmap.dart';

class User {
	@Tag(name: "creation_date")
	DateTime creationDate;
	
	@Tag(name: "last_name")
	String lastName;
	
	@Tag(name: "first_name")
	String firstName;
	
	int age;
	
	String toString() => "[$creationDate | $lastName | $firstName | $age]";
}

main() {
	var decoder = new Decoder(hook: (fromType, toType, val) {
		if (fromType == String && toType == DateTime) {
			return DateTime.parse(val);
		}
		return val;
	});
	var input = {
		"creation_date": "2019-03-17",
		"last_name": "Doe",
		"first_name": "John",
		"age": 42
	};
	var output = decoder.decode<User>(input);
	print(output); // [2019-03-17 00:00:00.000 | Doe | John | 42]
}

```

## FAQ

* **Why using mirros ?** This library is oriented to be simple to use and mirrors allow a dynamisme which can offers 
nice things
* **On which plateform can it be used ?** only on [server]() and [flutter]()

## Authors

* [PLATEL Kevin]()
