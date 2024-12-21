import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

class GeminiHandler {
  static const String _modelId = 'gemini-1.5-flash-8b';

  /// Sends a message to Gemini and retrieves the response.
  static Future<String?> getResponse(String message) async {
    try {
      final apiKey = 'AIzaSyB26rIHnDN1FVFNx0TWbGkcn0FNidRBjfc';
      final model = GenerativeModel(
        model: _modelId,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.8,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
          responseMimeType: 'application/json', // Set MIME type to JSON
        ),
        systemInstruction: Content.system(
          "Gemini is an AI-powered assistant integrated into the Orion project app to analyze chats within "
          "project groups and provide relevant insights or references. It is not a chatbot but a contextual tool "
          "for enhancing productivity and collaboration.\n\n"
          "Behavior Rules:\n"
          "1. Identify keywords dynamically from the conversation. Examples include 'generate', 'need', 'want', 'prefer', "
          "'documentation', 'API', 'example', 'tutorial', or any similar words requesting or in need for information or resources. Also if the user wants to watch or learn or anything related to a project for which the resources can be given, provide them.\n"
          "2. When documentation is explicitly requested, fetch and provide the official documentation link from the web.Also provide when the user meets a roadblock or has issues during projects\n"
          "3. Provide concise, professional responses without conversational tone. Respond only when context requires your input.\n"
          "4. Include URLs separately when appropriate to avoid cluttering the response.\n"
          "5. Ignore irrelevant messages and maintain silence unless explicitly required to assist.\n"
          "6. When providing URLs (e.g., documentation or tutorials), include a very brief two-line summary explaining the content of the link.\n"
          "7. For YouTube video requests, search for the most relevant video online and return its URL with a concise summary.\n"
          "8. Respond only to relevant queries while maintaining professionalism and avoiding casual interactions.\n"
          "9. The response should be in 3 key-value pairs: message url and summary. If no reponse required then send empty json\n"
        ),
      );

      final chat = model.startChat();
      final content = Content.text(
          "This is the message sent by the user in the chat: $message");
      final response = await chat.sendMessage(content);

      if (response.text != null) {
        print(
            "HEHEHEHEHEHEEHEEEHEHEHEHEHEHEHEHHEHEHEHEHEHEHEHHEHEHEHEHEHEHEHHEHEHEHEHEHEHHHH ${response}");
        print(response.text);

        try {
          // Decode the response text into JSON format
          final jsonResponse = jsonDecode(response.text!);

          if (jsonResponse is Map<String, dynamic>) {
            // Extract URLs if they exist in the 'urls' key
            final urls = jsonResponse['url'];

            if (urls != null) {
              print("Extracted URLs: $urls");
            } else {
              print("No URLs found in the response.");
            }
          } else {
            print("Response is not in the expected JSON format.");
          }
        } catch (e) {
          print("Error decoding JSON response: $e");
        }
        if (response.text != '{}') {
          print(
              "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
          return response.text;
        } // Return the original JSON response.
        else {
          print("---------------------------------------------------");
          return null;
        }
      }

      return null;
    } catch (e) {
      print('Error fetching response: $e');
      return null;
    }
  }
}
