import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_generator/View/Screens/bloc/quiz_customization_bloc.dart';
import 'package:test_generator/View/Screens/bloc/quiz_customization_event.dart';
import 'package:test_generator/View/Screens/bloc/quiz_customization_state.dart';
import 'package:test_generator/View/Screens/Quizz/quizScreen.dart';

class QuizCustomizationScreen extends StatefulWidget {
  @override
  _QuizCustomizationScreenState createState() =>
      _QuizCustomizationScreenState();
}

class _QuizCustomizationScreenState extends State<QuizCustomizationScreen> {
  int _selectedSource = -1;
  final TextEditingController _textController = TextEditingController();
  String? _selectedFileName;
  PlatformFile? _selectedFile;

  Widget _getInputSection() {
    if (_selectedSource == 0) {
      // Document upload section
      return Column(
        children: [
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 2),
              color: Colors.grey[50],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_outlined,
                    size: 48, color: Colors.purple),
                SizedBox(height: 12),
                if (_selectedFileName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Selected file: $_selectedFileName',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                Text(
                  'Upload your document here',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      try {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'doc', 'docx'],
                        );

                        if (result != null) {
                          setState(() {
                            _selectedFile = result.files.first;
                            _selectedFileName = result.files.first.name;
                          });
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                  'Supported formats: PDF, DOCX',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (_selectedSource == 1) {
      // Text input section
      return Column(
        children: [
          SizedBox(height: 24),
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
    return BlocProvider(
      create: (context) => QuizCustomizationBloc(),
      child: BlocConsumer<QuizCustomizationBloc, QuizCustomizationState>(
        listener: (context, state) {
          if (state is QuizCustomizationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is QuizCustomizationSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => QuizScreen(quizId: state.quizId),
              ),
            );
          }
        },
        builder: (context, state) {
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
                if (state is QuizCustomizationLoading)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.purple),
                          SizedBox(height: 16),
                          Text(
                            "Generating your quiz...",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New Quiz',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 24),
                          InkWell(
                            onTap: () => setState(() => _selectedSource = 0),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedSource == 0
                                      ? Colors.purple
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                                color: _selectedSource == 0
                                    ? Colors.purple[50]
                                    : Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.file_copy,
                                      color: _selectedSource == 0
                                          ? Colors.purple
                                          : Colors.grey),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Upload Document',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: _selectedSource == 0
                                                ? Colors.purple
                                                : Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Upload PDF or Word documents',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_selectedSource == 0)
                                    Icon(Icons.check_circle,
                                        color: Colors.purple),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          InkWell(
                            onTap: () => setState(() => _selectedSource = 1),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedSource == 1
                                      ? Colors.purple
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                                color: _selectedSource == 1
                                    ? Colors.purple[50]
                                    : Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.text_fields,
                                      color: _selectedSource == 1
                                          ? Colors.purple
                                          : Colors.grey),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Enter Text Manually',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: _selectedSource == 1
                                                ? Colors.purple
                                                : Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Type or paste your text directly',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_selectedSource == 1)
                                    Icon(Icons.check_circle,
                                        color: Colors.purple),
                                ],
                              ),
                            ),
                          ),
                          _getInputSection(),
                          if (_selectedSource != -1) ...[
                            SizedBox(height: 32),
                            SizedBox(
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
                                  final bloc =
                                      context.read<QuizCustomizationBloc>();
                                  if (_selectedSource == 0 &&
                                      _selectedFile != null) {
                                    bloc.add(UploadDocument(_selectedFile!));
                                  } else if (_selectedSource == 1 &&
                                      _textController.text.trim().isNotEmpty) {
                                    bloc.add(EnterTextManually(
                                        _textController.text.trim()));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Please provide content first')),
                                    );
                                  }
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
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
