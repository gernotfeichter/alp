import 'package:android/crypt/crypt.dart';
import 'package:android/logging/logging.dart';

void main() async {
  var key = "passwordpasswordpasswordpassword";
  var plaintext = "secret-text";

  var encrypted = encryptAES(plaintext, key);
  print("Ciphertext: ${encrypted}");
  var decrypted = decryptAES(encrypted, key);

  assert(plaintext == decrypted);

	assert(decryptAES("nIj/ThHqhT9lrBKM1kl4MA==", key) == plaintext); // ciphertext from this dart implementation TODO: Gernot
	log.info("First test succeeded");
  assert(decryptAES("ZfcADiJjwprQw6K34wDzw5wWN3XYagLOQ8Wo", key) == plaintext); // ciphertext from go implementation
}