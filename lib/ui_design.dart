import 'package:flutter/material.dart';  

/// 设置区域组件  
class SettingsSection extends StatefulWidget {  
  final String maskChar;  
  final String interval;  
  final double fontSize;  
  final ValueChanged<String> onMaskCharChanged;  
  final ValueChanged<String> onIntervalChanged;  
  final ValueChanged<double> onFontSizeChanged;  
  final ValueChanged<String> onProcessText;  

  const SettingsSection({  
    super.key,  
    required this.maskChar,  
    required this.interval,  
    required this.fontSize,  
    required this.onMaskCharChanged,  
    required this.onIntervalChanged,  
    required this.onFontSizeChanged,  
    required this.onProcessText,  
  });  

  @override  
  _SettingsSectionState createState() => _SettingsSectionState();  
}  

class _SettingsSectionState extends State<SettingsSection> {  
  late TextEditingController _maskCharController;  

  @override  
  void initState() {  
    super.initState();  
    _maskCharController = TextEditingController(text: widget.maskChar);  
  }  

  @override  
  void didUpdateWidget(covariant SettingsSection oldWidget) {  
    super.didUpdateWidget(oldWidget);  
    if (widget.maskChar != oldWidget.maskChar) {  
      _maskCharController.text = widget.maskChar;  
    }  
  }  

  @override  
  void dispose() {  
    _maskCharController.dispose();  
    super.dispose();  
  }  

  @override  
  Widget build(BuildContext context) {  
    return Card(  
      child: Padding(  
        padding: const EdgeInsets.all(16.0),  
        child: Column(  
          children: [  
            Row(  
              children: [  
                const Text('隔字符：'),  
                const SizedBox(width: 8),  
                SizedBox(  
                  width: 50,  
                  child: TextField(  
                    controller: _maskCharController,  
                    onChanged: widget.onMaskCharChanged,  
                    textAlign: TextAlign.center,  
                    maxLength: 1,  
                    decoration: const InputDecoration(  
                      counterText: '',  
                      border: OutlineInputBorder(),  
                    ),  
                  ),  
                ),  
                const SizedBox(width: 16),  
                const Text('间隔数：'),  
                const SizedBox(width: 8),  
                DropdownButton<String>(  
                  value: widget.interval,  
                  items: const [  
                    DropdownMenuItem(value: '1', child: Text('1')),  
                    DropdownMenuItem(value: '2', child: Text('2')),  
                    DropdownMenuItem(value: '3', child: Text('3')),  
                    DropdownMenuItem(value: '4', child: Text('4')),  
                    DropdownMenuItem(value: '5', child: Text('5')),  
                    DropdownMenuItem(value: 'random', child: Text('随机')),  
                  ],  
                  onChanged: (value) {  
                    if (value != null) {  
                      widget.onIntervalChanged(value);  
                    }  
                  },  
                ),  
              ],  
            ),  
            const SizedBox(height: 16),  
            Row(  
              children: [  
                const Text('字体大小：'),  
                Expanded(  
                  child: Slider(  
                    value: widget.fontSize,  
                    min: 12,  
                    max: 36,  
                    divisions: 12,  
                    label: widget.fontSize.round().toString(),  
                    onChanged: widget.onFontSizeChanged,  
                  ),  
                ),  
              ],  
            ),  
            const SizedBox(height: 16),  
            Row(  
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,  
              children: [  
                ElevatedButton(  
                  onPressed: () => widget.onProcessText('char'),  
                  child: const Text('字符遮蔽'),  
                ),  
                ElevatedButton(  
                  onPressed: () => widget.onProcessText('word'),  
                  child: const Text('单词遮蔽'),  
                ),  
              ],  
            ),  
          ],  
        ),  
      ),  
    );  
  }  
}  

/// 文本区域组件  
class TextSection extends StatefulWidget {  
  final String text;  
  final String processedText;  
  final double fontSize;  
  final ValueChanged<String> onTextChanged;  
  final VoidCallback onFileUpload;  
  final VoidCallback onSave;  
  final VoidCallback onFullScreen;
  final VoidCallback onClear;  

  const TextSection({  
    super.key,  
    required this.text,  
    required this.processedText,  
    required this.fontSize,  
    required this.onTextChanged,  
    required this.onFileUpload,  
    required this.onSave,  
    required this.onFullScreen,
    required this.onClear,  
  });  

  @override  
  _TextSectionState createState() => _TextSectionState();  
}  

class _TextSectionState extends State<TextSection> {  
  late TextEditingController _textController;  

  @override  
  void initState() {  
    super.initState();  
    _textController = TextEditingController(text: widget.text);  
  }  

  @override  
  void didUpdateWidget(covariant TextSection oldWidget) {  
    super.didUpdateWidget(oldWidget);  
    if (widget.text != oldWidget.text) {  
      _textController.text = widget.text;  
    }  
  }  

  @override  
  void dispose() {  
    _textController.dispose();  
    super.dispose();  
  }  

  @override  
  Widget build(BuildContext context) {  
    return Card(  
      child: Column(  
        children: [  
          Padding(  
            padding: const EdgeInsets.all(16.0),  
            child: TextField(  
              controller: _textController,  
              onChanged: widget.onTextChanged,  
              maxLines: 5,  
              decoration: const InputDecoration(  
                labelText: '输入文本',  
                border: OutlineInputBorder(),  
              ),  
            ),  
          ),  
          Padding(  
            padding: const EdgeInsets.symmetric(horizontal: 16.0),  
            child: Row(  
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,  
              children: [  
                ElevatedButton(  
                  onPressed: widget.onFileUpload,  
                  child: const Text('上传文件'),  
                ),  
                ElevatedButton(  
                  onPressed: widget.onSave,  
                  child: const Text('保存'),  
                ),  
                ElevatedButton(  
                  onPressed: widget.onFullScreen,  
                  child: const Text('全屏'),  
                ),
                ElevatedButton(
                  onPressed: widget.onClear,
                  child: const Text('清空'),
                ),
              ],  
            ),  
          ),  
          const SizedBox(height: 16),  
          Padding(  
            padding: const EdgeInsets.all(16.0),  
            child: Container(  
              width: double.infinity,  
              padding: const EdgeInsets.all(16),  
              decoration: BoxDecoration(  
                border: Border.all(color: Colors.grey),  
                borderRadius: BorderRadius.circular(4),  
              ),  
              child: Text(  
                widget.processedText,  
                style: TextStyle(fontSize: widget.fontSize),  
              ),  
            ),  
          ),  
        ],  
      ),  
    );  
  }  
}