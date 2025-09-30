import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Service for exporting transcripts and summaries to various formats
class ExportService {
  /// Export transcript and summary as plain text
  Future<void> exportAsText({
    required String transcript,
    required String summary,
    required DateTime createdAt,
    String? title,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(createdAt);
    final fileName = title != null
        ? '${_sanitizeFileName(title)}_$formattedDate.txt'
        : 'transcription_$formattedDate.txt';

    final content = _formatTextContent(
      transcript: transcript,
      summary: summary,
      createdAt: createdAt,
      title: title,
    );

    await _shareContent(content, fileName, 'text/plain');
  }

  /// Export only transcript as plain text
  Future<void> exportTranscriptOnly({
    required String transcript,
    required DateTime createdAt,
    String? title,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(createdAt);
    final fileName = title != null
        ? '${_sanitizeFileName(title)}_transcript_$formattedDate.txt'
        : 'transcript_$formattedDate.txt';

    await _shareContent(transcript, fileName, 'text/plain');
  }

  /// Export only summary as plain text
  Future<void> exportSummaryOnly({
    required String summary,
    required DateTime createdAt,
    String? title,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(createdAt);
    final fileName = title != null
        ? '${_sanitizeFileName(title)}_summary_$formattedDate.txt'
        : 'summary_$formattedDate.txt';

    await _shareContent(summary, fileName, 'text/plain');
  }

  /// Export transcript and summary as markdown
  Future<void> exportAsMarkdown({
    required String transcript,
    required String summary,
    required DateTime createdAt,
    String? title,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(createdAt);
    final fileName = title != null
        ? '${_sanitizeFileName(title)}_$formattedDate.md'
        : 'transcription_$formattedDate.md';

    final content = _formatMarkdownContent(
      transcript: transcript,
      summary: summary,
      createdAt: createdAt,
      title: title,
    );

    await _shareContent(content, fileName, 'text/markdown');
  }

  /// Export transcript and summary as JSON
  Future<void> exportAsJson({
    required String transcript,
    required String summary,
    required DateTime createdAt,
    String? title,
    Map<String, dynamic>? additionalData,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(createdAt);
    final fileName = title != null
        ? '${_sanitizeFileName(title)}_$formattedDate.json'
        : 'transcription_$formattedDate.json';

    final data = {
      'title': title ?? 'Untitled',
      'createdAt': createdAt.toIso8601String(),
      'transcript': transcript,
      'summary': summary,
      if (additionalData != null) ...additionalData,
    };

    final content = _formatJsonContent(data);
    await _shareContent(content, fileName, 'application/json');
  }

  /// Export transcript and summary as PDF
  Future<void> exportAsPdf({
    required String transcript,
    required String summary,
    required DateTime createdAt,
    String? title,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(createdAt);
    final fileName = title != null
        ? '${_sanitizeFileName(title)}_$formattedDate.pdf'
        : 'transcription_$formattedDate.pdf';

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return [
            if (title != null)
              pw.Header(
                level: 0,
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Created: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt)}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text(
                'Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              summary,
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
            ),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 1,
              child: pw.Text(
                'Transcript',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              transcript,
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5),
            ),
          ];
        },
      ),
    );

    // Save PDF to temporary directory
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    // Share the PDF file
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: fileName,
    );
  }

  String _formatTextContent({
    required String transcript,
    required String summary,
    required DateTime createdAt,
    String? title,
  }) {
    final buffer = StringBuffer();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt);

    if (title != null) {
      buffer.writeln(title);
      buffer.writeln('=' * title.length);
      buffer.writeln();
    }

    buffer.writeln('Created: $formattedDate');
    buffer.writeln();
    buffer.writeln('SUMMARY');
    buffer.writeln('-------');
    buffer.writeln(summary);
    buffer.writeln();
    buffer.writeln('TRANSCRIPT');
    buffer.writeln('----------');
    buffer.writeln(transcript);

    return buffer.toString();
  }

  String _formatMarkdownContent({
    required String transcript,
    required String summary,
    required DateTime createdAt,
    String? title,
  }) {
    final buffer = StringBuffer();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt);

    if (title != null) {
      buffer.writeln('# $title');
      buffer.writeln();
    }

    buffer.writeln('**Created:** $formattedDate');
    buffer.writeln();
    buffer.writeln('## Summary');
    buffer.writeln();
    buffer.writeln(summary);
    buffer.writeln();
    buffer.writeln('## Transcript');
    buffer.writeln();
    buffer.writeln(transcript);

    return buffer.toString();
  }

  String _formatJsonContent(Map<String, dynamic> data) {
    // Pretty print JSON with 2 space indentation
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  Future<void> _shareContent(
    String content,
    String fileName,
    String mimeType,
  ) async {
    try {
      // Write content to a temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);

      // Share the file using SharePlus
      await Share.shareXFiles(
        [XFile(file.path, mimeType: mimeType)],
        subject: fileName,
      );
    } catch (e) {
      throw Exception('Failed to export: $e');
    }
  }

  String _sanitizeFileName(String fileName) {
    // Remove or replace invalid characters
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }
}