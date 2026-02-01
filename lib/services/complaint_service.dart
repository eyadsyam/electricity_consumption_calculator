import 'dart:convert';

import 'package:http/http.dart' as http;

class ComplaintService {
  static Future<bool> sendComplaint({
    required String name,
    required String email,
    required String phone,
    required String date,
    required String message,
  }) async {
    final url = Uri.parse(
      "https://YOUR_PROJECT_ID.functions.supabase.co/sendComplaintEmail",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "phone": phone,
        "date": date,
        "message": message,
      }),
    );

    return response.statusCode == 200;
  }
}
