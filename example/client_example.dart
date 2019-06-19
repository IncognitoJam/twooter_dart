import 'package:twooter_dart/twooter_dart.dart';

main() async {
  final client = TwooterClient(apiUrl: 'http://localhost');
  print(client.apiUrl);

  final up = await client.isUp();
  print('up: ${up}');
}
