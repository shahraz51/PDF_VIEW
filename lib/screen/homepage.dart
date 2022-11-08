import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/screen/view_pdf.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? date;
  String? getUrl;

  Future<void> uploadfile(File file) async {
    if (file == null) {
      return null;
    }
    date = DateFormat.yMMMMd().add_jm().format(DateTime.now());
    final url =
        FirebaseStorage.instance.ref().child('files').child("$date.pdf");

    final metadata = SettableMetadata(
        contentType: 'file/pdf',
        customMetadata: {'picked-file-path': file.path});
    await url.putData(await file.readAsBytes(), metadata);
    getUrl = await url.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("file").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Text(
                  "loading",
                  style: TextStyle(fontSize: 20, color: Colors.black38),
                ),
              );
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text(
                "UPload File ",
                style: TextStyle(fontSize: 20, color: Colors.black38),
              ));
            }
            final datasnap = snapshot.data!.docs;

            return ListView.builder(
              itemCount: datasnap.length,
              itemBuilder: (ctx, i) =>
                  ViewPDf(datasnap[i]["Url"], datasnap[i]["Date"]),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.cloud_upload_outlined),
          onPressed: () async {
            final path = await FlutterDocumentPicker.openDocument();
            File file = File(path!);

            await uploadfile(file);

            FirebaseFirestore.instance.collection("file").add({
              "Date": date,
              "Url": getUrl,
            });
          },
        ));
  }
}
