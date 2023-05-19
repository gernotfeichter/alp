import 'package:android/crypt/crypt.dart';
import 'package:android/logging/logging.dart';
import 'dart:convert' as convert;

void main() async {
  var key = "passwordpassword";
  var plaintext = "secret-text";

  print(convert.utf8.encode(plaintext)) ;

  var encrypted = encryptAES(plaintext, key);
  print("Ciphertext: ${encrypted}");
  var decrypted = decryptAES(encrypted, key);

  assert(plaintext == decrypted);

	assert(decryptAES("Nb5lHLauPblZHko1dM75gg==", key) == plaintext); // ciphertext from this dart implementation TODO: Gernot
	log.info("First test succeeded");
  assert(decryptAES("y6+ySUhbULZ9fffhKYhS9zWoc4ayUH13lloT", key) == plaintext); // ciphertext from go implementation
}