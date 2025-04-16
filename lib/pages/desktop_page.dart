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

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      if (file.bytes != null) {
        setState(() {
          fileContent = utf8.decode(file.bytes!);
        });
        await _submitCodeReview(fileContent!);
      } else {
        print("No bytes available for the selected file.");
      }
    } else {
      print("No file selected");
    }
  }

  Future<void> _submitCodeReview(String code) async {
    final url = Uri.parse("https://jaga001.pythonanywhere.com/code_review");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"code": code}),
      );

      if (response.statusCode == 200) {
        setState(() {
          codeReviewOutput = jsonDecode(response.body)["review"];
          isTyping = true;
        });
      } else {
        setState(() {
          codeReviewOutput =
              "Failed to retrieve code review: ${response.statusCode}";
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
                        child: fileContent == null
                            ? GridView.builder(
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
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade800,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: const EdgeInsets.all(8.0),
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
                                  );
                                },
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
                        child: isTyping
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
                                ),
                              ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 15),
                    child: OutlinedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 20),
                        ),
                      ),
                      onPressed: _pickFile,
                      child: const Text('Upload a File'),
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