import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiService {
  final String baseUrl = "http://104.154.76.47:8000/inspect";

  Future<InspectionResult?> inspect(File imageFile) async {
    final uri = Uri.parse(baseUrl);

    var request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    var streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return InspectionResult.fromJson(
          Map<String, dynamic>.from(await Future.value(
        // decode manually to avoid stack traces
        jsonDecode(response.body),
      )));
    } else {
      print("API ERROR: ${response.body}");
      return null;
    }
  }
}
