import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class CieChatScreen extends StatefulWidget {
  final String title;
  final String userId;

  CieChatScreen({required this.title, required this.userId});

  @override
  _CieChatScreenState createState() => _CieChatScreenState();
}

class _CieChatScreenState extends State<CieChatScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  File? _selectedFile;
  String? _fileName;
  String _description = '';
  bool _isUploading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      if (fileName.endsWith('.pdf') ||
          fileName.endsWith('.docx') ||
          fileName.endsWith('.xlsx') ||
          fileName.endsWith('.pptx') ||
          fileName.endsWith('.jpg') ||
          fileName.endsWith('.jpeg') ||
          fileName.endsWith('.png')) {
        setState(() {
          _selectedFile = file;
          _fileName = fileName;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unsupported file format!')),
        );
      }
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile != null && _description.isNotEmpty) {
      setState(() {
        _isUploading = true;
      });

      String filePath = 'uploads/${widget.userId}/${widget.title}/$_fileName';
      String? fileUrl = await _firebaseService.uploadFile(_selectedFile!, filePath);

      if (fileUrl != null) {
        await _firebaseService.saveFileData(
          widget.title,
          fileUrl,
          _fileName!,
          _description,
          widget.userId,
        );

        setState(() {
          _selectedFile = null;
          _fileName = null;
          _description = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file!')),
        );
      }

      setState(() {
        _isUploading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a file and add a description!')),
      );
    }
  }

  Widget _buildFilePreview() {
    return _selectedFile != null
        ? Card(
      elevation: 4,
      margin: EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected File',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(_fileName ?? 'No file selected'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Add a description',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadFile,
              icon: _isUploading
                  ? CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                  : Icon(Icons.upload),
              label: Text('Upload File'),
            ),
          ],
        ),
      ),
    )
        : Container();
  }

  Widget _buildFileList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(widget.title)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.attach_file),
                title: Text(doc['fileName']),
                subtitle: Text(doc['description']),
                trailing: Icon(Icons.download, color: Theme.of(context).primaryColor),
                onTap: () {
                  // Open the file link
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Expanded(child: _buildFileList()),
          _buildFilePreview(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
