
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<String?> uploadFile(File file, String path) async {
try {
final ref = _storage.ref(path);
await ref.putFile(file);
return await ref.getDownloadURL();
} catch (e) {
print("Upload Error: $e");
return null;
}
}

Future<void> saveFileData(String collection, String fileUrl, String fileName, String description, String userId) async {
await _firestore.collection(collection).add({
'userId': userId,
'fileUrl': fileUrl,
'fileName': fileName,
'description': description,
'timestamp': FieldValue.serverTimestamp(),
});
}
}