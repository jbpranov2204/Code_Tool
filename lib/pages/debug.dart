import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DebugPage extends StatefulWidget {
  final String geminiApiKey;

  const DebugPage({Key? key, required this.geminiApiKey}) : super(key: key);

  @override
  _DebugPageState createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  String? fileContent; // Variable to hold the file content
  String? codeReviewOutput; // Variable to hold API response
  bool isTyping = false;
  String selectedAnalysisType =
      'Check this code for errors or logic issues and recommend fixes.'; // Default analysis type for debugging

  @override
  void initState() {
    super.initState();
  }

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
    
    ## Potential Errors
    [List any potential errors or bugs]
    
    ## Logic Issues
    [Point out any logical flaws or suboptimal implementations]
    
    ## Improvement Suggestions
    [Provide specific code improvement suggestions with examples]
    """;

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash-lite:generateContent?key=${widget.geminiApiKey}',
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
            codeReviewOutput = responseText;
            isTyping = false;
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

  // Desktop view of Debug page
  Widget _buildDesktopView() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: Text(
              'Select File to Debug',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          SizedBox(height: 20),
          if (fileContent != null)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade700),
                      ),
                      padding: EdgeInsets.all(15),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          fileContent!,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Courier',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade700),
                      ),
                      padding: EdgeInsets.all(15),
                      child: SingleChildScrollView(
                        child:
                            codeReviewOutput != null
                                ? MarkdownBody(
                                  data: codeReviewOutput!,
                                  styleSheet: MarkdownStyleSheet(
                                    p: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    h1: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    h2: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                                : Center(
                                  child: Text(
                                    'Debug output will appear here',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.code, size: 60, color: Colors.grey.shade600),
                      SizedBox(height: 20),
                      Text(
                        'No file selected',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Please select a code file to debug',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Mobile view of Debug page
  Widget _buildMobileView() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: _pickFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(
              'Select File to Debug',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          SizedBox(height: 20),
          if (fileContent != null)
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [Tab(text: 'Code'), Tab(text: 'Analysis')],
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Code Tab
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade700),
                            ),
                            padding: EdgeInsets.all(15),
                            margin: EdgeInsets.only(top: 10),
                            child: SingleChildScrollView(
                              child: SelectableText(
                                fileContent!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Courier',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                          // Analysis Tab
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade700),
                            ),
                            padding: EdgeInsets.all(15),
                            margin: EdgeInsets.only(top: 10),
                            child: SingleChildScrollView(
                              child:
                                  codeReviewOutput != null
                                      ? MarkdownBody(
                                        data: codeReviewOutput!,
                                        styleSheet: MarkdownStyleSheet(
                                          p: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                          h1: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          h2: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                      : Center(
                                        child: Text(
                                          'Debug output will appear here',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.code, size: 60, color: Colors.grey.shade600),
                      SizedBox(height: 20),
                      Text(
                        'No file selected',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Please select a code file to debug',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're on a mobile device based on screen width
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return isMobile ? _buildMobileView() : _buildDesktopView();
  }
}
