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

	// assert(decryptAES("nIj/ThHqhT9lrBKM1kl4MA==", key) == plaintext); // ciphertext from this dart implementation TODO: Gernot
	log.info("First test succeeded");
  assert(decryptAES("HQBNSQf3CZa09RUHqPB1tBCazQXPJ+eGgH3x", key) == plaintext); // ciphertext from go implementation
}