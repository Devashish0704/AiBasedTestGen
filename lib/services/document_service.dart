import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:file_picker/file_picker.dart';

class DocumentService {
  /// Extracts text from a file based on its type
  static Future<String?> extractTextFromFile(PlatformFile file) async {
    try {
      if (file.path == null) return null;
      final extension = path.extension(file.path!).toLowerCase();

      switch (extension) {
        case '.pdf':
          return await _extractFromPDF(file.path!);
        case '.docx':
          return await _extractFromDOCX(file.path!);
        case '.doc':
          throw UnsupportedError(
              'Legacy .doc files are not supported. Please save as .docx');
        default:
          throw UnsupportedError('Unsupported file type: $extension');
      }
    } catch (e) {
      print('Error extracting text: $e');
      return null;
    }
  }

  /// Extract text from PDF file using Syncfusion
  static Future<String?> _extractFromPDF(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text;
    } catch (e) {
      print('Error extracting PDF text: $e');
      return null;
    }
  }

  /// Extract text from DOCX file using docx_to_text
  static Future<String?> _extractFromDOCX(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      return await docxToText(bytes);
    } catch (e) {
      print('Error extracting DOCX text: $e');
      return null;
    }
  }
}
