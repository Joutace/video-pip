import 'package:flutter/material.dart';
import 'package:video_rotate/core/initialize.dart';
import 'package:video_rotate/views/lessons_list_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LessonsListView(),
    ),
  );
}
