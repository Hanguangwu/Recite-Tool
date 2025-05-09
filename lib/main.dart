import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth.dart';      // 你的用户认证页面
import 'ui_design.dart'; // 包含 SettingsSection 和 TextSection
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'database.dart';
import 'file_picker_handler.dart';  

void main() {  
  runApp(const MyApp());  
}  

class MyApp extends StatelessWidget {  
  const MyApp({super.key});  

  @override  
  Widget build(BuildContext context) {  
    return MaterialApp(  
      title: '诵读',  
      theme: ThemeData(  
        primarySwatch: Colors.blue,  
      ),  
      home: const MemoryToolPage(),  
    );  
  }  
}  

class MemoryToolPage extends StatefulWidget {  
  final String? initialText;
  const MemoryToolPage({super.key, this.initialText});  

  @override  
  State<MemoryToolPage> createState() => _MemoryToolPageState();  
}  

class _MemoryToolPageState extends State<MemoryToolPage> {  
  String text = '';
  
  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      text = widget.initialText!;
    }
  }
  String processedText = '';
  String maskChar = 'X';
  String interval = '3';  // 也可以是 'random'
  double fontSize = 20.0;
  bool isFullScreen = false;
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _titleController = TextEditingController();  
  // 这里可加入登录状态管理，如 bool _isLoggedIn = false;  

  Future<void> _pickFile() async {
    String? content = await FilePickerHandler.pickTextFile(context);
    if (content != null) {
      setState(() {
        text = content;
      });
    }
  }

  Future<void> _saveToLocal() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入文档标题')),
      );
      return;
    }
    
    await _dbService.saveDocument(_titleController.text, text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('文档已保存到本地')),
    );
  }

  /// 文件上传处理函数
  Future<void> _handleFileUpload() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        String content = String.fromCharCodes(file.bytes!);
        setState(() {
          text = content;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('文件上传失败: ${e.toString()}')),
      );
    }
  }

  /// 保存处理函数
  Future<void> _handleSave() async {
    try {
      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入要保存的文本')),
        );
        return;
      }

      await _dbService.saveDocument(
        '文档_${DateTime.now().millisecondsSinceEpoch}',
        text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: ${e.toString()}')),
      );
    }
  }

  String _processWithFixedInterval(String input, String mode, int interval) {  
    switch (mode) {
      case 'chinese':
        // 中文处理：按字符间隔遮蔽
        return input.split('').asMap().entries.map((e) {
          return (e.key + 1) % interval == 0 ? maskChar : e.value;
        }).join('');
      
      case 'english_sentence':
        // 英文句子处理：按单词间隔遮蔽
        return input.split(' ').map((word) {
          return word.length > 2 
              ? word[0] + maskChar * (word.length - 2) + word[word.length - 1] 
              : word;
        }).join(' ');
      
      case 'japanese':
        // 日语处理：按字符间隔遮蔽
        return input.split('').asMap().entries.map((e) {
          return (e.key + 1) % interval == 0 ? maskChar : e.value;
        }).join('');
      
      case 'english_word':
      default:
        // 英文单词处理：按字母间隔遮蔽
        return input.split('').asMap().entries.map((e) {
          return (e.key + 1) % interval == 0 ? maskChar : e.value;
        }).join('');
    }
  }  

  String _processWithRandomInterval(String input, String mode) {  
    final random = Random();
    switch (mode) {
      case 'chinese':
        // 中文随机遮蔽
        return input.split('').map((char) {
          return random.nextDouble() > 0.7 ? maskChar : char;
        }).join('');
      
      case 'english_sentence':
        // 英文句子随机遮蔽
        return input.split(' ').map((word) {
          return random.nextDouble() > 0.7 
              ? word[0] + maskChar * (word.length - 2) + word[word.length - 1] 
              : word;
        }).join(' ');
      
      case 'japanese':
        // 日语随机遮蔽
        return input.split('').map((char) {
          return random.nextDouble() > 0.7 ? maskChar : char;
        }).join('');
      
      case 'english_word':
      default:
        // 英文单词随机遮蔽
        return input.split('').map((char) {
          return random.nextDouble() > 0.7 ? maskChar : char;
        }).join('');
    }
  }  

  void processText(String mode) {  
    if (text.isEmpty) {  
      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(content: Text('请先输入或上传文本')),  
      );  
      return;  
    }  

    setState(() {  
      if (interval == 'random') {  
        processedText = _processWithRandomInterval(text, mode);  
      } else {  
        processedText = _processWithFixedInterval(text, mode, int.parse(interval));  
      }  
    });  
  }  

  void _saveToDatabase() {  
    // TODO: 实现保存逻辑（比如保存到本地数据库或云端）  
    ScaffoldMessenger.of(context).showSnackBar(  
      const SnackBar(content: Text('保存功能未实现')),  
    );  
  }  

  void _showFullScreenDialog() {  
    showDialog(  
      context: context,  
      builder: (_) {  
        return Dialog(  
          child: Container(  
            color: Colors.white,  
            padding: const EdgeInsets.all(20),  
            constraints: BoxConstraints(  
              maxHeight: MediaQuery.of(context).size.height * 0.8,  
              maxWidth: MediaQuery.of(context).size.width * 0.9,  
            ),  
            child: SingleChildScrollView(  
              child: Text(  
                processedText,  
                style: TextStyle(fontSize: fontSize),  
              ),  
            ),  
          ),  
        );  
      },  
    );  
  }  

  // 用户认证相关功能可以在这里处理，比如登录状态管理、按钮跳转，略。  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(  
        title: const Text('记忆工具——背个X啊'),  
        actions: [  
          IconButton(  
            icon: const Icon(Icons.history),  
            onPressed: () {  
              // 打开历史记录页面  
              Navigator.push(  
                  context, MaterialPageRoute(builder: (_) => HistoryScreen()));  
            },  
          ),  
          // 这里可以基于登录状态，显示不同图标和跳转  
          IconButton(  
            icon: const Icon(Icons.person),  
            onPressed: () {  
              Navigator.push(  
                  context, MaterialPageRoute(builder: (_) => AuthWidget()));  
            },  
          ),  
        ],  
      ),  
      body: SingleChildScrollView(  
        padding: const EdgeInsets.all(16.0),  
        child: Column(  
          children: [  
            // 语言模式选择
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => processText('chinese'),
                  child: Text('中文'),
                ),
                ElevatedButton(
                  onPressed: () => processText('english_sentence'),
                  child: Text('英文句子'),
                ),
                ElevatedButton(
                  onPressed: () => processText('japanese'),
                  child: Text('日语'),
                ),
                ElevatedButton(
                  onPressed: () => processText('english_word'),
                  child: Text('英文单词'),
                ),
              ],
            ),
            SizedBox(height: 20),
            SettingsSection(  
              maskChar: maskChar,  
              interval: interval,  
              fontSize: fontSize,  
              onMaskCharChanged: (value) {  
                if (value.isNotEmpty) {  
                  setState(() => maskChar = value);  
                }  
              },  
              onIntervalChanged: (value) => setState(() => interval = value),  
              onFontSizeChanged: (value) => setState(() => fontSize = value),  
              onProcessText: processText,  
            ),  
            const SizedBox(height: 16),  
            TextSection(  
              text: text,  
              processedText: processedText,  
              fontSize: fontSize,  
              onTextChanged: (value) => setState(() => text = value),  
              onFileUpload: _handleFileUpload,  
              onSave: _handleSave,  
              onFullScreen: _showFullScreenDialog,
              onClear: () => setState(() => text = ''),  
            ),  
          ],  
        ),  
      ),  
    );  
  }  
}  

/// 历史记录页面的简单示例  
class HistoryScreen extends StatefulWidget {  
  @override  
  _HistoryScreenState createState() => _HistoryScreenState();  
}  

class _HistoryScreenState extends State<HistoryScreen> {  
  final DatabaseService _dbService = DatabaseService();  
  List<Map<String, dynamic>> _documents = [];  

  @override  
  void initState() {  
    super.initState();  
    _loadDocuments();  
  }  

  Future<void> _loadDocuments() async {  
    final documents = await _dbService.getAllDocuments();  
    setState(() {  
      _documents = documents;  
    });  
  }  

  Future<void> _deleteDocument(int id) async {  
    await _dbService.deleteDocument(id);  
    await _loadDocuments();  
  }  

  void _showDocumentDetail(Map<String, dynamic> document) {  
    showDialog(  
      context: context,  
      builder: (_) => AlertDialog(  
        title: Text(document['title']),  
        content: SingleChildScrollView(  
          child: Text(document['content']),  
        ),  
        actions: [  
          TextButton(  
            onPressed: () => Navigator.pop(context),  
            child: const Text('关闭'),  
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: document['content']));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制到剪贴板')),
              );
            },
            child: const Text('复制'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MemoryToolPage(initialText: document['content']),
                ),
              );
            },
            child: const Text('跳转到主页面'),
          ),
        ],  
      ),  
    );  
  }  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(  
        title: const Text('历史记录'),  
        actions: [  
          IconButton(  
            icon: const Icon(Icons.close),  
            onPressed: () => Navigator.pop(context),  
          ),  
        ],  
      ),  
      body: ListView.builder(  
        itemCount: _documents.length,  
        itemBuilder: (context, index) {  
          final doc = _documents[index];  
          return ListTile(  
            title: Text(doc['title']),  
            subtitle: Text(doc['created_at']),  
            trailing: Row(  
              mainAxisSize: MainAxisSize.min,  
              children: [  
                IconButton(  
                  icon: const Icon(Icons.delete),  
                  onPressed: () => _deleteDocument(doc['id']),  
                ),  
                IconButton(  
                  icon: const Icon(Icons.open_in_new),  
                  onPressed: () => _showDocumentDetail(doc),  
                ),  
              ],  
            ),  
          );  
        },  
      ),  
    );  
  }  
}