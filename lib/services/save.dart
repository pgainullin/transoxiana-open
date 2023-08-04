// Future<void> save({Id? id, required String jsonMap}) async {
//   //TODO: overwrite check
//   //TODO: web work-around with auth? other local storage?

//   if (jsonMap.isNotEmpty) {
//     final Directory documents = await getApplicationDocumentsDirectory();
//     final File saveFile = File('${documents.path}/${id ?? 'quicksave.tos'}');

//     await saveFile.writeAsString(jsonMap);

//     log(
//         'File ${documents.path}/${id ?? 'quicksave.tos'} saved successfully at ${DateTime.now()}');
//   } else {
//     throw 'Save data is empty';
//   }
// }

// Future<String> load({String? id}) async {
//   final Directory documents = await getApplicationDocumentsDirectory();
//   final path = '${documents.path}/${id ?? 'quicksave.tos'}';
//   final File saveFile = File(path);
//   if (!saveFile.existsSync()) {
//     log('File $path not found');
//     return '';
//   }
//   final String contents = await saveFile.readAsString();
//   log('File $path loaded successfully at ${DateTime.now()}');

//   return contents;
// }

// Future<bool> saveExists({String? id}) async {
//   if (kIsWeb) return false;

//   final Directory documents = await getApplicationDocumentsDirectory();
//   final File saveFile = File('${documents.path}/${id ?? 'quicksave.tos'}');

//   return saveFile.existsSync();
// }
