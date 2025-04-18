import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GitRepoPage extends StatefulWidget {
  final String geminiApiKey;

  const GitRepoPage({Key? key, required this.geminiApiKey}) : super(key: key);

  @override
  _GitRepoPageState createState() => _GitRepoPageState();
}

class _GitRepoPageState extends State<GitRepoPage>
    with TickerProviderStateMixin {
  // GitHub repo related variables
  final TextEditingController _repoUrlController = TextEditingController();
  bool _isProcessingRepo = false;
  String? _repoProcessStatus;
  String? _repoName;
  List<String> _repoFiles = [];
  int _currentFileIndex = -1;
  String? fileContent; // Variable to hold the file content
  String? codeReviewOutput; // Variable to hold API response
  bool isTyping = false;
  String selectedAnalysisType =
      'Review this code for readability and best practices. Suggest improvements.';

  TabController? _repoTabController; // For desktop GitHub UI
  TabController? _mobileRepoTabController; // For mobile GitHub UI

  @override
  void initState() {
    super.initState();
    // Will be initialized when repo files are loaded
  }

  @override
  void dispose() {
    _repoUrlController.dispose();
    _repoTabController?.dispose();
    _mobileRepoTabController?.dispose();
    super.dispose();
  }

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
    if (treeResp.statusCode != 200) {
      throw Exception("Could not fetch repo tree");
    }
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
      _repoTabController?.dispose();
      _repoTabController = null;
      _mobileRepoTabController?.dispose();
      _mobileRepoTabController = null;
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
        // Initialize tab controllers after files are loaded
        _repoTabController = TabController(length: 2, vsync: this);
        _mobileRepoTabController = TabController(length: 2, vsync: this);
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

    // Switch to Analysis tab (index 1) for both desktop and mobile
    _repoTabController?.animateTo(1);
    _mobileRepoTabController?.animateTo(1);

    setState(() {
      codeReviewOutput = "Analyzing entire repository...";
      isTyping = true;
    });

    try {
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

  // Mobile version of GitHub UI
  Widget _buildMobileView() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
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
          SizedBox(height: 16),

          ElevatedButton.icon(
            icon: Icon(Icons.cloud_download),
            label: Text('Analyze Repository'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              minimumSize: Size(double.infinity, 50),
            ),
            onPressed: _isProcessingRepo ? null : _processGitRepository,
          ),

          SizedBox(height: 16),

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
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: _analyzeRepositoryWithGemini,
                  ),
                  SizedBox(height: 10),
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
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Clear Repository',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

          // Files and analysis for mobile (stacked vertically)
          if (_repoFiles.isNotEmpty)
            Expanded(
              child: Column(
                children: [
                  // Files list with horizontal scrolling
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _repoFiles.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => _loadRepositoryFile(index),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color:
                                      index == _currentFileIndex
                                          ? Colors.blue
                                          : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              _repoFiles[index].split('/').last,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    index == _currentFileIndex
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // Expandable sections for code and analysis
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      initialIndex: _mobileRepoTabController?.index ?? 0,
                      child: Builder(
                        builder: (context) {
                          // Attach controller if available
                          if (_mobileRepoTabController != null) {
                            DefaultTabController.of(
                              context,
                            )?.animation?.addListener(() {});
                            DefaultTabController.of(context)?.index =
                                _mobileRepoTabController!.index;
                          }
                          return Column(
                            children: [
                              TabBar(
                                controller: _mobileRepoTabController,
                                tabs: [
                                  Tab(text: 'Code'),
                                  Tab(text: 'Analysis'),
                                ],
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: Colors.blue,
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _mobileRepoTabController,
                                  children: [
                                    // Code Tab
                                    Container(
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade900,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
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
                                                    'Select a file to view its content',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                      ),
                                    ),

                                    // Analysis Tab
                                    Container(
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade900,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
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
                                                      isRepeatingAnimation:
                                                          false,
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
                                                          color:
                                                              Colors.lightBlue,
                                                          fontSize: 14,
                                                          backgroundColor:
                                                              Colors.black38,
                                                        ),
                                                        codeblockPadding:
                                                            EdgeInsets.all(8),
                                                        codeblockDecoration:
                                                            BoxDecoration(
                                                              color:
                                                                  Colors
                                                                      .black45,
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
                            ],
                          );
                        },
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

  // Desktop version of GitHub UI
  Widget _buildDesktopView() {
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
                    child: DefaultTabController(
                      length: 2,
                      initialIndex: _repoTabController?.index ?? 0,
                      child: Builder(
                        builder: (context) {
                          // Attach controller if available
                          if (_repoTabController != null) {
                            DefaultTabController.of(
                              context,
                            )?.animation?.addListener(() {});
                            DefaultTabController.of(context)?.index =
                                _repoTabController!.index;
                          }
                          return Column(
                            children: [
                              TabBar(
                                controller: _repoTabController,
                                tabs: [
                                  Tab(text: 'Code'),
                                  Tab(text: 'Analysis'),
                                ],
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: Colors.blue,
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _repoTabController,
                                  children: [
                                    // Code Tab
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade900,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(15),
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
                                    // Analysis Tab
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade900,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(15),
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
                                                      isRepeatingAnimation:
                                                          false,
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
                                                          color:
                                                              Colors.lightBlue,
                                                          fontSize: 14,
                                                          backgroundColor:
                                                              Colors.black38,
                                                        ),
                                                        codeblockPadding:
                                                            EdgeInsets.all(8),
                                                        codeblockDecoration:
                                                            BoxDecoration(
                                                              color:
                                                                  Colors
                                                                      .black45,
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
                            ],
                          );
                        },
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

  @override
  Widget build(BuildContext context) {
    // Determine if we're on a mobile device based on screen width
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return isMobile ? _buildMobileView() : _buildDesktopView();
  }
}
