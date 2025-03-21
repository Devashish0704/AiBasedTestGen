import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class QuizCustomizationScreen extends StatefulWidget {
  @override
  _QuizCustomizationScreenState createState() =>
      _QuizCustomizationScreenState();
}

class _QuizCustomizationScreenState extends State<QuizCustomizationScreen> {
  int _selectedSource = -1;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  Widget _getInputSection() {
    if (_selectedSource == 0) {
      // Document upload section
      return Column(
        children: [
          SizedBox(height: 24),
          _buildStepHeader("3", "Upload Document"),
          SizedBox(height: 16),
          _buildUploadSection(),
        ],
      );
    } else if (_selectedSource == 1) {
      // Text input section
      return Column(
        children: [
          SizedBox(height: 24),
          _buildStepHeader("3", "Enter Your Text"),
          SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: "Paste or type your text here...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.purple, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      );
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New Quiz',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  _buildStepHeader("1", "Select your Quiz Source"),
                  SizedBox(height: 16),
                  _buildOptionButton(0, "Document",
                      "Upload PDF, PowerPoint, Word & More", Icons.file_copy),
                  _buildOptionButton(1, "Text",
                      "Paste your text or write topic", Icons.text_fields),
                  if (_selectedSource != -1) ...[
                    SizedBox(height: 24),
                    _buildStepHeader("2", "Quiz Details"),
                    SizedBox(height: 16),
                    _buildTextField("Quiz Name", "Give your quiz a name", 25),
                    SizedBox(height: 16),
                    _buildTextField(
                        "Description", "Add a description (optional)", 100),
                    _getInputSection(),
                    SizedBox(height: 32),
                    _buildGenerateButton(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String number, String title) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.purple[100],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.purple[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildOptionButton(
      int index, String title, String subtitle, IconData icon) {
    bool isSelected = _selectedSource == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => setState(() => _selectedSource = index),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.purple : Colors.grey[300]!,
              width: 2,
            ),
            color: isSelected ? Colors.purple[50] : Colors.white,
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.purple : Colors.grey),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.purple : Colors.black,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: Colors.purple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, int maxLength) {
    return TextField(
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple, width: 2),
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 2),
        color: Colors.grey[50],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.purple),
          SizedBox(height: 12),
          Text(
            'Drag and drop your file here',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            'or',
            style: TextStyle(color: Colors.grey),
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                try {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
                  );

                  if (result != null) {
                    PlatformFile file = result.files.first;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Selected file: ${file.name}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    print('File path: ${file.path}');
                    print(
                        'File size: ${(file.size / 1024).toStringAsFixed(2)} KB');
                    print('File extension: ${file.extension}');
                  }
                } catch (e) {
                  print("Error picking file: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error picking file: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.purple[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.file_upload, color: Colors.purple),
                  SizedBox(width: 8),
                  Text(
                    'Browse files',
                    style: TextStyle(color: Colors.purple),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Supported formats: PDF, DOCX, PPTX',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          // Add generation logic
          Navigator.pop(context);
        },
        child: Text(
          "Generate Quiz",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _textController.dispose();
    super.dispose();
  }
}
