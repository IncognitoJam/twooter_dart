Unofficial Twooter library for Dart developers.

## Usage

A simple usage example:

```dart
import 'package:twooter_dart/twooter_dart.dart';

main() async {
  final client = TwooterClient();

  // Check the twooter service status
  final bool isUp = await client.isUp();
  print(isUp); // true

  // Register a new user account (you should save the token for later!)
  final username = 'dart-dev';
  final String token = await client.registerName(username);
  print(token); // 12345-abcd... (the user token)

  // Post a message
  final message = 'Hello, world! #myfirsttwoot';
  final String id = await client.sendMessage(token, username, message);
  print(id); // 12345-abcd... (the message id)

  // Retrieve latest messages
  final List<Message> messages = await client.getMessages();
  print(messages); // [{ id: 12345..., message: 'Hello, world!...', ... }, ...]
}
```

Check out the [test suite][tests] for more examples of the library's
functionality as well as the code documentation which you can generate by
running `dartdoc` in the root of the repository.


## Features and bugs

Features:
- Check the Twooter service online status: `Future<bool> isUp()`
- Register a username and retrieve it's token: `Future<String> registerName(name)`
- Check whether or not a particular user has been registered: `Future<bool> isActiveName()`
- Get the latest list of messages from Twooter: `Future<List<Message>> getMessages()`
- Post a new message to Twooter: `Future<String> postMessage(token, name, message)`
- and much more!

Bugs:
- Nothing known yet.


## Future improvements
I plan to add support for the live feed and events from the Twooter Server in
future, although it is not required.


Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/IncognitoJam/twooter_dart
[tests]: https://github.com/IncognitoJam/twooter_dart/blob/master/test/twooter_dart_test.dart
