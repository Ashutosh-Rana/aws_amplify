import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

final AmplifyLogger _logger = AmplifyLogger('MyStorageApp');

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   // _checkAuthStatus();
  // }

  Future<void> _signOut() async {
    try {
      await Amplify.Auth.signOut();
      Navigator.pushNamed(context, "/login");
      _logger.debug('Signed out');
    } on AuthException catch (e) {
      _logger.error('Could not sign out - ${e.message}');
    }
  }

  // Future<void> _checkAuthStatus() async {
  //   try {
  //     final session = await Amplify.Auth.fetchAuthSession();
  //     _logger.debug('Signed in: ${session.isSignedIn}');
  //   } on AuthException catch (e) {
  //     _logger.error('Could not check auth status - ${e.message}');
  //   }
  // }

  Future<void> _uploadFile() async {
    safePrint("inside upload function");
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
      withReadStream: true,
      withData: false,
    );

    if (result == null) {
      safePrint("No file selected");
      _logger.debug('No file selected');
      return;
    }

    final platformFile = result.files.single;

    try {
      await Amplify.Storage.uploadFile(
          localFile: AWSFile.fromStream(
            platformFile.readStream!,
            size: platformFile.size,
          ),
          key: platformFile.name,
          onProgress: (p) => {
                _logger
                    .debug('Uploading: ${p.transferredBytes}/${p.totalBytes}'),
                safePrint('Uploading: ${p.transferredBytes}/${p.totalBytes}')
              }).result;
      safePrint("Image Uploaded Successfully");

      // await _listAllPublicFiles();
    } on StorageException catch (e) {
      safePrint("error in upload File - ${e.message}");
      _logger.error('Error uploading file - ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image'),
      ),
      body: Stack(
        children: [
          // upload file button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _uploadFile,
                child: const Text('Upload File'),
              ),
            ),
          ),
          // sign out button
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                ),
                onPressed: _signOut,
                child: const Icon(Icons.logout, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
