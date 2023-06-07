import 'dart:io';

import 'package:alp/crypt/aes_gcm_256_pbkdf2_string_encryption.dart';

void main() {
  var encrypted = "zRgaonmXy+Yw9jyf8PwW0X9z7Hwv1738X4X2coLf/vM=:ZLnedKZm04V3v+5A:4O3GCXdqyJ73iKMwp1paHQ==:dXzVZy2Fs/iKOuOolZp2TQ==";
  var decrypted = aesGcmPbkdf2DecryptFromBase64("GYTpQ8GRE23YOgB1DK0FBwUATnKPJliW", encrypted);
  if ("{\"secret\":\"abc\"}" != decrypted) {
    exit(1);
  }
}
