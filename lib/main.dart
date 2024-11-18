import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Contact>> contacts = Future.value([].cast<Contact>());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Awd"),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                requestPermissions();
                contacts = getContacts();
              },
              child: Text("Get Contacts"))
        ],
      ),
    );
  }

  Future<List<Contact>> getContacts() async {
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    print("${contacts.toList()[0].displayName} gg");
    return contacts.toList();
  }

  Future<void> requestPermissions() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      await Permission.contacts.request();
    }
  }
}
