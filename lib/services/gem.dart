import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<String> generateChatSummary(List<String> chatContent) async {
  try {
    final model = GenerativeModel(
      model: 'gemini-pro', // Replace with the correct model ID
      apiKey:
          "AIzaSyDBlIHNfPQqWOhGf6DC49B071psVYRxwB4", // Replace with your API key
    );
    String content = "";

    for (var traveller in chatContent) {
      content += "\n" + traveller;
    }

    String prompt = """
    Please create a concise meeting minutes summary from the following chat discussion:

    ${content}

    Please include:
    1. Key discussion points
    2. Decisions made
    3. Action items
    4. Next steps

    Format the summary in a clear, professional manner.
    """;

    final response = await model.generateContent([Content.text(prompt)]);
    if (response.text != null && response.text!.isNotEmpty) {
      // Directly return the summary as a string
      return response.text!;
    } else {
      return ''; // Return empty string if no text is generated
    }
  } catch (e) {
    return 'Error: ${e.toString()}'; // Return error message as string
  }
}

Future<String> generateDiyaChatSummary(String chatContent) async {
  try {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-8b', // Replace with the correct model ID
      apiKey:
          "AIzaSyDBlIHNfPQqWOhGf6DC49B071psVYRxwB4", // Replace with your API key
    );

    String prompt = """
    Otherwise, make sure to create a concise meeting minutes summary from the following chat discussion:

    Input details:
    - Chat Content: ${chatContent}

    Referring the above input details, follow the below format for output content:
    Meeting Summary: [Insert topic]

    Attendees:
    [List of attendees]

    Key Discussion Points:
    [Point 1]
    [Point 2]
    [Point 3]

    Decisions Made:
    [Person 1] decided [Action/Decision 1].
    [Person 2] agreed on [Action/Decision 2].

    Action Items:
    [Assignee Name]: [Task 1], [Task 2]

    Next Steps:
    [Step 1]
    [Step 2]
    """;

    final response = await model.generateContent([Content.text(prompt)]);
    if (response.text != null && response.text!.isNotEmpty) {
      // Directly return the meeting summary as a string
      print(
          "Thisssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss-${response.text}");
      return response.text!;
    } else {
      return ''; // Return empty string if no text is generated
    }
  } catch (e) {
    return 'Error: ${e.toString()}'; // Return error message as string
  }
}
