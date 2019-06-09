Unofficial Twooter library for Dart developers.

## Usage

A simple usage example:

```dart
import 'package:twooter_dart/twooter_dart.dart';

main() async {
  final client = TwooterClient();

  // Check the twooter service status
  final isUp = await client.isUp();
  print(isUp); // true

  // Register a new user account (you should save the token for later!)
  final username = 'dart-dev';
  final token = await client.registerName(username);
  print(token); // 12345-abcd...
}
```

## Features and bugs
- Check the Twooter service online status: `Future<bool> isUp()`
- Register a username and retrieve it's token: `Future<String> registerName(name)`
- Check whether or not a particular user has been registered: `Future<bool> isActiveName()`
- Get the latest list of messages from Twooter: `Future<List<Message>> getMessages()`


## Future improvements
There is lots to do to match the functionality of the original Java client, including:
- Posting messages to Twooter
- Retrieving messages by their ID
- Refreshing user tokens
- Searching for messages by the author name and tags
- and lots more!


Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/IncognitoJam/twooter_dart
