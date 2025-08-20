import 'package:encrypt/encrypt.dart' as encrypt;
class EncryptionHelper
{
  static final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');  //32 char key
  static final iv = encrypt.IV.fromLength(16);      //initializing vector
  static final encrypter = encrypt.Encrypter(encrypt.AES(key));

  static String encryptdata(String text)
  {
    final encrypted = encrypter.encrypt(text,iv: iv);
    return encrypted.base64;
  }
  static String decryptData(String text) {
    try {
      return encrypter.decrypt64(text, iv: iv);
    } catch (e) {
      return text;
    }
  }

}