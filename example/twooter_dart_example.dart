import 'package:twooter_dart/twooter_dart.dart';

main() async {
  var client = TwooterClient();
  var up = await client.isUp();
  print('isUp: ${up}');
}
