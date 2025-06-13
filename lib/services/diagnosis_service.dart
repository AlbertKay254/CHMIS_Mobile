import 'dart:convert';
import 'package:http/http.dart' as http;

class DiagnosisService {
  static Future<List<Map<String, dynamic>>> getDiagnosisByPatient(String patientID) async {
    final url = Uri.parse('http://192.168.1.10:3030/api/diagnosis/$patientID');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load diagnosis for patient');
    }
  }
}
