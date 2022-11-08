import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class ViewPDf extends StatefulWidget {
  String date;
  String url;
  ViewPDf({required this.date,required this.url});

  @override
  State<ViewPDf> createState() => _ViewPDfState();
}

class _ViewPDfState extends State<ViewPDf> {
  String remotePDFpath = "";
  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    final filename = widget.url.substring(widget.url.lastIndexOf("/") + 9);
    var request = await HttpClient().getUrl(Uri.parse(widget.url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    var dir = await getApplicationDocumentsDirectory();
    File file = File("${dir.path}/$filename");

    await file.writeAsBytes(bytes, flush: true);
    completer.complete(file);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(widget.date.toString()),
        onTap: () {
          createFileOfPdfUrl().then((f) => {
                remotePDFpath = f.path,
              });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RenderPdf(remotePDFpath)));
        },
      ),
    );
  }
}

class RenderPdf extends StatefulWidget {
  String? doc;
  RenderPdf(this.doc);

  @override
  State<RenderPdf> createState() => _RenderPdfState();
}

class _RenderPdfState extends State<RenderPdf> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      margin: EdgeInsets.all(10.0),
      child: PDFView(
        filePath: widget.doc,
      ),
    );
  }
}
