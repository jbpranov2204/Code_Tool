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

        setState(() {
          codeReviewOutput = responseText ?? "No analysis could be generated.";
          isTyping = true;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          ResponsiveDrawer(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 200),
                  Center(
                    child: SizedBox(
                      height: 400,
                      width: 500,
                      child: Scrollbar(
                        child:
                            fileContent == null
                                ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Select Analysis Type:",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: GridView.builder(
                                        padding: const EdgeInsets.all(10.0),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 10,
                                              crossAxisSpacing: 10,
                                              childAspectRatio: 2.5,
                                            ),
                                        itemCount: prompt.length,
                                        itemBuilder: (context, index) {
                                          final selected = prompt[index];
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedAnalysisType = selected;
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    selectedAnalysisType ==
                                                            selected
                                                        ? Colors.blue.shade800
                                                        : Colors.grey.shade800,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border:
                                                    selectedAnalysisType ==
                                                            selected
                                                        ? Border.all(
                                                          color: Colors.white,
                                                          width: 2,
                                                        )
                                                        : null,
                                              ),
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  selected,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                                : SingleChildScrollView(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade800,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      fileContent!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                      ),
                    ),
                  ),
                  if (codeReviewOutput != null)
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            isTyping
                                ? AnimatedTextKit(
                                  animatedTexts: [
                                    TyperAnimatedText(
                                      codeReviewOutput!,
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      speed: const Duration(milliseconds: 10),
                                    ),
                                  ],
                                  isRepeatingAnimation: false,
                                  onFinished: () {
                                    setState(() {
                                      isTyping = false;
                                    });
                                  },
                                )
                                : MarkdownBody(
                                  data: codeReviewOutput!,
                                  styleSheet: MarkdownStyleSheet(
                                    p: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    h1: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    h2: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    code: const TextStyle(
                                      color: Colors.lightBlue,
                                      fontSize: 14,
                                      backgroundColor: Colors.black38,
                                    ),
                                    codeblockPadding: const EdgeInsets.all(8),
                                    codeblockDecoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50.0,
                      vertical: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 20,
                              ),
                            ),
                          ),
                          onPressed: _pickFile,
                          child: const Text('Upload a File'),
                        ),
                        if (fileContent != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: OutlinedButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  fileContent = null;
                                  codeReviewOutput = null;
                                });
                              },
                              child: const Text('New Analysis'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
