import 'package:code_tool/components/drawer.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class DesktopPage extends StatefulWidget {
  DesktopPage({super.key});

  @override
  _DesktopPageState createState() => _DesktopPageState();
}

class _DesktopPageState extends State<DesktopPage> {
  final List<String> prompt = [
    'Review this code for readability and best practices. Suggest improvements.',
    'Check this code for errors or logic issues and recommend fixes.',
    'Scan this code for security risks and suggest mitigations.',
    'Analyze for performance bottlenecks and recommend optimizations.',
  ];

  String? fileContent; // Variable to hold the file content
  String? codeReviewOutput; // Variable to hold API response
  bool isTyping = false;
  String selectedAnalysisType =
      'Review this code for readability and best practices. Suggest improvements.'; // Default analysis type
  final String _geminiApiKey =
      'AIzaSyBlbhZsd6sxlQf1FbVZiYN6f3eJY6um1CE'; // Replace with your API key

  bool showQueryField = false; // To toggle the query field
  final TextEditingController queryController = TextEditingController();
  String? responseMessage;

  bool showChatbotUI = false; // To toggle the chatbot UI
  final TextEditingController messageController = TextEditingController();
  final List<String> chatMessages = []; // To store chat messages

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      if (file.bytes != null) {
        setState(() {
          fileContent = utf8.decode(file.bytes!);
        });
        await _analyzeCodeWithGemini(fileContent!, file.name ?? "Unknown file");
      } else {
        print("No bytes available for the selected file.");
      }
    } else {
      print("No file selected");
    }
  }

  String _guessLanguageFromFilename(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'py':
        return 'Python';
      case 'java':
        return 'Java';
      case 'js':
        return 'JavaScript';
      case 'ts':
        return 'TypeScript';
      case 'c':
        return 'C';
      case 'cpp':
      case 'cc':
        return 'C++';
      case 'cs':
        return 'C#';
      case 'go':
        return 'Go';
      case 'rb':
        return 'Ruby';
      case 'php':
        return 'PHP';
      case 'html':
        return 'HTML';
      case 'css':
        return 'CSS';
      case 'swift':
        return 'Swift';
      case 'kt':
        return 'Kotlin';
      case 'dart':
        return 'Dart';
      case 'rs':
        return 'Rust';
      default:
        return 'Unknown';
    }
  }

  Future<void> _analyzeCodeWithGemini(String code, String filename) async {
    setState(() {
      codeReviewOutput = "Analyzing your code...";
      isTyping = true;
    });

    final language = _guessLanguageFromFilename(filename);
    final requestPrompt = """
    Act as an expert $language developer and code reviewer. Analyze the following $language code:
    
    ```
    $code
    ```
    
    $selectedAnalysisType
    
    Provide your analysis in the following structured format:
    
    ## Summary
    [Brief summary of the code's purpose and overall quality]
    
    ## Code Style Issues
    [List any code style issues]
    
    ## Potential Errors
    [List any potential errors or bugs]
    
    ## Logic Issues
    [Point out any logical flaws or suboptimal implementations]
    
    ## Improvement Suggestions
    [Provide specific code improvement suggestions with examples]
    """;

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash-lite:generateContent?key=$_geminiApiKey',
    );

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": requestPrompt},
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
        if (responseText == null) {
          setState(() {
            codeReviewOutput = "No analysis could be generated.";
            isTyping = false;
          });
        } else {
          setState(() {
            codeReviewOutput = responseText ?? "No analysis could be generated.";
            isTyping = true;
          });
        }
      } else {
        setState(() {
          codeReviewOutput = "Error: ${response.statusCode}\n${response.body}";
          isTyping = false;
        });
      }
    } catch (error) {
      setState(() {
        codeReviewOutput = "Error: $error";
        isTyping = false;
      });
    }
  }

  void handleCodeReviewTap() {
    setState(() {
      showChatbotUI = true;
    });
  }

  void handleSendQuery() {
    setState(() {
      responseMessage = "This is a random response to your query: '${queryController.text}'";
      queryController.clear();
    });
  }

  void handleSendMessage() {
    if (messageController.text.isNotEmpty) {
      setState(() {
        chatMessages.add("You: ${messageController.text}");
        chatMessages.add("Bot: This is a random response to your query.");
        messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Row(
        children: [
          ResponsiveDrawer(
            onCodeReviewTap: handleCodeReviewTap,
            onDebugThisCodeForMeTap: () {},
          ),
          Expanded(
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20.0),
                  color: Colors.grey.shade900,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.notifications_outlined, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.settings_outlined, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: showChatbotUI
                      ? Container(
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
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Align(
                                        alignment: chatMessages[index].startsWith("You:")
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.all(12.0),
                                          decoration: BoxDecoration(
                                            color: chatMessages[index].startsWith("You:")
                                                ? Colors.blue.shade700
                                                : Colors.grey.shade700,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            chatMessages[index],
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
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Statistics Cards
                              Row(
                                children: [
                                  _buildStatCard(
                                    'Code Reviews',
                                    '24',
                                    Icons.code,
                                    Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildStatCard(
                                    'Debug Sessions',
                                    '12',
                                    Icons.bug_report,
                                    Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildStatCard(
                                    'Git Reviews',
                                    '8',
                                    Icons.gite,
                                    Colors.purple.shade700,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Recent Activity Section
                              Text(
                                'Recent Activity',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildRecentActivityList(),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(icon, color: color),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey.shade700,
          height: 1,
        ),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade700,
              child: Icon(Icons.code, color: Colors.white),
            ),
            title: Text(
              'Code Review #${index + 1}',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '2 hours ago',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade500),
          );
        },
      ),
    );
  }
}
