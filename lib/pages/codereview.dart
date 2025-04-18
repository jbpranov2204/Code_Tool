import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CodeReviewPage extends StatefulWidget {
  final String geminiApiKey;

  const CodeReviewPage({Key? key, required this.geminiApiKey})
    : super(key: key);

  @override
  _CodeReviewPageState createState() => _CodeReviewPageState();
}

class _CodeReviewPageState extends State<CodeReviewPage> {
  final TextEditingController messageController = TextEditingController();
  final List<String> chatMessages = []; // To store chat messages

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void handleSendMessage() async {
    if (messageController.text.isEmpty) return;

    final userMessage = messageController.text;
    setState(() {
      chatMessages.add("You: $userMessage");
      messageController.clear();
    });

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash-lite:generateContent?key=${widget.geminiApiKey}',
    );

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text": """
          If the following message is a general query, respond in a helpful and conversational manner in Markdown format. 
          If it is related to code debugging or you're provided with code snippets, please:
          
          1. Format the code with proper indentation and alignment
          2. Use appropriate syntax highlighting with triple backticks and language name
          3. Organize the response with clear hierarchical headings
          4. Break down complex solutions into step-by-step explanations
          
          For long code blocks:
          - Restructure the code with consistent spacing (4 spaces for indentation)
          - Align related elements vertically (like parameters, assignments, etc.)
          - Add line breaks between logical sections
          - Insert descriptive comments for complex logic
          - Format method chains with one method per line when appropriate
          - For very long lines, break them at logical points
          - Ensure proper bracket alignment and placement
          
          Message: "$userMessage"
          
          Respond appropriately based on the context of the message, focusing on clarity and readability.
          """,
            },
          ],
        },
      ],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseText =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        setState(() {
          chatMessages.add(
            // Instead of plain text, store a special marker for markdown rendering
            "BotMarkdown: ${responseText ?? "I couldn't generate a response. Please try again."}",
          );
        });
      } else {
        setState(() {
          chatMessages.add("Bot: Error: ${response.statusCode}");
        });
      }
    } catch (error) {
      setState(() {
        chatMessages.add("Bot: Error: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final msg = chatMessages[index];
                final isUser = msg.startsWith("You:");
                final isMarkdown = msg.startsWith("BotMarkdown:");
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isUser
                                ? Colors.blue.shade700
                                : Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          isMarkdown
                              ? MarkdownBody(
                                data: msg.replaceFirst("BotMarkdown: ", ""),
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(color: Colors.white),
                                  code: TextStyle(
                                    color: Colors.lightBlue,
                                    fontSize: 14,
                                    backgroundColor: Colors.black38,
                                  ),
                                  codeblockPadding: EdgeInsets.all(8),
                                  codeblockDecoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              )
                              : Text(
                                msg,
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Chat Input Section
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: handleSendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
