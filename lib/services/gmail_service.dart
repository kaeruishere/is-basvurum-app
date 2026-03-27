import 'dart:convert';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';

class GmailService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      GmailApi.gmailSendScope,
      GmailApi.gmailReadonlyScope,
    ],
  );

  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    final httpClient = await _googleSignIn.authenticatedClient();
    if (httpClient == null) throw Exception('Google Sign-In failed');

    final gmailApi = GmailApi(httpClient);

    // RFC 2822 formatında mail oluşturma (basit versiyon)
    String message = 
        'To: $to\r\n'
        'Subject: $subject\r\n'
        'Content-Type: text/html; charset="UTF-8"\r\n\r\n'
        '$body';

    List<int> bytes = List<int>.from(message.codeUnits);
    String base64Message = base64Url.encode(bytes);

    final Message mailMessage = Message();
    mailMessage.raw = base64Message;

    await gmailApi.users.messages.send(mailMessage, 'me');
  }
}
