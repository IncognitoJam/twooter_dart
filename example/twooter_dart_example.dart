import 'dart:io';

import 'package:twooter_dart/twooter_dart.dart';

main() async {
  final client = TwooterClient();
  final up = await client.isUp();
  print('isUp: ${up}');

  final socket = await Socket.connect('twooter.johnvidler.co.uk', 1337);
  socket.listen((data) {
    final message = String.fromCharCodes(data).trim();
    print(message);
  });
//  final listener = (event) {
//    print("event: ${event}");
//  };
//  client.addEventListener(listener);
//  client.enableLiveFeed();
}
