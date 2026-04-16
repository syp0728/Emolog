import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> sendToLlama(String userInput) async {
  final uri = Uri.parse('http://172.17.177.67:8080/completion');

  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    },
    body: jsonEncode({
      "prompt": userInput,
      "n_predict": 128,
      "temperature": 0.7,
    }),
  );

  // if (response.statusCode == 200) {
  //   final data = jsonDecode(response.body);
  //   return data['content'] ?? "No response";
  // } else {
  //   return 'Error: ${response.statusCode}';
  // }

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final content = data['content'] ?? '';
    if (content.trim().isEmpty) {
      print('⚠️ LLM responded with empty content.');
      return 'No content from LLM';
    }
    return content;
  } else {
    print('❌ LLM request failed: ${response.statusCode}');
    return 'Error: ${response.statusCode}';
  }
}
