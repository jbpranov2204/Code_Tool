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
  bool showGitReview = false; // To toggle the GitHub review UI
  bool showDebugPage = false; // To toggle the debug page UI
  final TextEditingController messageController = TextEditingController();
  final List<String> chatMessages = []; // To store chat messages

  // GitHub repo related variables
  final TextEditingController _repoUrlController = TextEditingController();
  bool _isProcessingRepo = false;
  String? _repoProcessStatus;
  String? _repoName;
  List<String> _repoFiles = [];
  int _currentFileIndex = -1;

  bool isGitHubFeatureEnabled =
      false; // Flag to control GitHub feature availability

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

  // GitHub repository methods
  Future<List<String>> _fetchGitHubFiles(String repoUrl) async {
    // Extract owner and repo name from URL
    final uri = Uri.parse(repoUrl);
    final segments = uri.pathSegments;
    if (segments.length < 2) throw Exception("Invalid GitHub repo URL");
    final owner = segments[0];
    final repo = segments[1].replaceAll('.git', '');

    // Get default branch
    final repoApiUrl = 'https://api.github.com/repos/$owner/$repo';
    final repoResp = await http.get(Uri.parse(repoApiUrl));
    if (repoResp.statusCode != 200) throw Exception("Repo not found");
    final repoData = jsonDecode(repoResp.body);
    final branch = repoData['default_branch'] ?? 'main';

    // Get file tree recursively
    final treeApiUrl =
        'https://api.github.com/repos/$owner/$repo/git/trees/$branch?recursive=1';
    final treeResp = await http.get(Uri.parse(treeApiUrl));
    if (treeResp.statusCode != 200)
      throw Exception("Could not fetch repo tree");
    final treeData = jsonDecode(treeResp.body);

    final List<String> files = [];
    for (final item in treeData['tree']) {
      if (item['type'] == 'blob') {
        files.add(item['path']);
      }
    }
    return files;
  }

  Future<void> _processGitRepository() async {
    final repoUrl = _repoUrlController.text.trim();
    if (repoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid repository URL')),
      );
      return;
    }

    setState(() {
      _isProcessingRepo = true;
      _repoProcessStatus = "Fetching repository information...";
      _repoFiles = [];
      _currentFileIndex = -1;
      fileContent = null;
      codeReviewOutput = null;
    });

    try {
      // Extract repo name from URL
      _repoName = repoUrl.split('/').last.replaceAll('.git', '');

      setState(() {
        _repoProcessStatus = "Repository found. Loading files...";
      });

      final files = await _fetchGitHubFiles(repoUrl);

      setState(() {
        _repoFiles = files;
        _repoProcessStatus = "Repository loaded successfully!";
        _isProcessingRepo = false;
      });
    } catch (error) {
      setState(() {
        _repoProcessStatus = "Error: $error";
        _isProcessingRepo = false;
      });
    }
  }

  Future<String> _fetchGitHubFileContent(
    String repoUrl,
    String filePath,
  ) async {
    final uri = Uri.parse(repoUrl);
    final segments = uri.pathSegments;
    if (segments.length < 2) throw Exception("Invalid GitHub repo URL");
    final owner = segments[0];
    final repo = segments[1].replaceAll('.git', '');

    // Get default branch
    final repoApiUrl = 'https://api.github.com/repos/$owner/$repo';
    final repoResp = await http.get(Uri.parse(repoApiUrl));
    if (repoResp.statusCode != 200) throw Exception("Repo not found");
    final repoData = jsonDecode(repoResp.body);
    final branch = repoData['default_branch'] ?? 'main';

    // Build raw file URL
    final rawUrl =
        'https://raw.githubusercontent.com/$owner/$repo/$branch/$filePath';
    final fileResp = await http.get(Uri.parse(rawUrl));
    if (fileResp.statusCode != 200)
      throw Exception("Could not fetch file content");
    return fileResp.body;
  }

  Future<void> _loadRepositoryFile(int index) async {
    if (index < 0 || index >= _repoFiles.length) return;

    setState(() {
      _currentFileIndex = index;
      fileContent = "Loading file content...";
      codeReviewOutput = null;
    });

    final filename = _repoFiles[index];

    try {
      final repoUrl = _repoUrlController.text.trim();
      final content = await _fetchGitHubFileContent(repoUrl, filename);

      setState(() {
        fileContent = content;
      });

      // Analyze the file with Gemini
      await _analyzeCodeWithGemini(content, filename);
    } catch (e) {
      setState(() {
        fileContent = "Error loading file: $e";
      });
    }
  }

  Future<void> _analyzeRepositoryWithGemini() async {
    if (_repoName == null) return;

    setState(() {
      codeReviewOutput = "Analyzing entire repository...";
      isTyping = true;
    });

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash-lite:generateContent?key=$_geminiApiKey',
      );

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": """
                Act as an expert code reviewer. I have a repository named $_repoName with the following structure:
                
                ${_repoFiles.join('\n')}
                
                $selectedAnalysisType
                
                Provide your analysis in the following structured format:
                
                ## Repository Overview
                [Brief overview of the repository structure and purpose]
                
                ## Key Findings
                [List major issues or insights about the codebase]
                
                ## Architecture Assessment
                [Comments on the architecture and organization]
                
                ## Improvement Recommendations
                [High-level improvement recommendations]
                """,
              },
            ],
          },
        ],
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseText =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        setState(() {
          codeReviewOutput = responseText ?? "No analysis could be generated.";
          isTyping = false;
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

  void handleCodeReviewTap() {
    setState(() {
      showChatbotUI = true;
      showGitReview = false;
      showDebugPage = false;
    });
  }

  void handleDebugThisCodeForMeTap() {
    setState(() {
      showDebugPage = true;
      showChatbotUI = false;
      showGitReview = false;
    });
    _pickFile();
  }

  void handleGitRepoReviewTap() {
    setState(() {
      showGitReview = true; // Navigate to GitHub functionalities UI
      showChatbotUI = false;
      showDebugPage = false;
    });
  }

  void handleSendQuery() {
    setState(() {
      responseMessage =
          "This is a random response to your query: '${queryController.text}'";
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
            onDebugThisCodeForMeTap: handleDebugThisCodeForMeTap,
            onGitRepoReviewTap: handleGitRepoReviewTap,
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
                        showGitReview
                            ? 'GitHub Repository Review'
                            : showDebugPage
                            ? 'Debug Code'
                            : showChatbotUI
                            ? 'Code Review Chat'
                            : 'Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child:
                      showGitReview
                          ? _buildGitHubUI()
                          : showDebugPage
                          ? _buildDebugPage()
                          : showChatbotUI
                          ? _buildChatbotUI()
                          : _buildDashboard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGitHubUI() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Repository URL input section
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _repoUrlController,
                  decoration: InputDecoration(
                    labelText: 'GitHub Repository URL',
                    labelStyle: TextStyle(color: Colors.white),
                    hintText: 'https://github.com/username/repository',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade800,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.link, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => _repoUrlController.clear(),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.cloud_download),
                label: Text('Analyze Repository'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                onPressed: _isProcessingRepo ? null : _processGitRepository,
              ),
            ],
          ),

          SizedBox(height: 20),

          // Repository processing status
          if (_isProcessingRepo || _repoProcessStatus != null)
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  if (_isProcessingRepo)
                    Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  SizedBox(height: 10),
                  Text(
                    _repoProcessStatus ?? '',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

          // Repository info section
          if (_repoName != null && !_isProcessingRepo)
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Repository: $_repoName',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Files: ${_repoFiles.length}',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.analytics),
                        label: Text('Analyze Entire Repository'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onPressed: _analyzeRepositoryWithGemini,
                      ),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _repoName = null;
                            _repoFiles = [];
                            _currentFileIndex = -1;
                            fileContent = null;
                            codeReviewOutput = null;
                            _repoProcessStatus = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Clear Repository',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Main content area (files list + code + analysis)
          if (_repoFiles.isNotEmpty)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Files list
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade700),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Repository Files:',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Divider(color: Colors.grey.shade700, height: 1),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _repoFiles.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.grey.shade300,
                                ),
                                title: Text(
                                  _repoFiles[index],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        index == _currentFileIndex
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                                selected: index == _currentFileIndex,
                                selectedTileColor: Colors.blue.withOpacity(0.2),
                                onTap: () => _loadRepositoryFile(index),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 16),

                  // Code and analysis section
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade700),
                            ),
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Code',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child:
                                        fileContent != null
                                            ? SelectableText(
                                              fileContent!,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Courier',
                                                fontSize: 14,
                                              ),
                                            )
                                            : Center(
                                              child: Text(
                                                'Select a file from the list to see its content',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade700),
                            ),
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Analysis',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child:
                                        codeReviewOutput != null
                                            ? isTyping
                                                ? AnimatedTextKit(
                                                  animatedTexts: [
                                                    TyperAnimatedText(
                                                      codeReviewOutput!,
                                                      textStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                      speed: Duration(
                                                        milliseconds: 10,
                                                      ),
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
                                                    p: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                    h1: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    h2: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    code: TextStyle(
                                                      color: Colors.lightBlue,
                                                      fontSize: 14,
                                                      backgroundColor:
                                                          Colors.black38,
                                                    ),
                                                    codeblockPadding:
                                                        EdgeInsets.all(8),
                                                    codeblockDecoration:
                                                        BoxDecoration(
                                                          color: Colors.black45,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4,
                                                              ),
                                                        ),
                                                  ),
                                                )
                                            : Center(
                                              child: Text(
                                                'Analysis will appear here',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDebugPage() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Debug Code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
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

  Widget _buildChatbotUI() {
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Align(
                    alignment:
                        chatMessages[index].startsWith("You:")
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color:
                            chatMessages[index].startsWith("You:")
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
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
        separatorBuilder:
            (context, index) => Divider(color: Colors.grey.shade700, height: 1),
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
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade500,
            ),
          );
        },
      ),
    );
  }
}
