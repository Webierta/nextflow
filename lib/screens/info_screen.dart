import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';

import '../styles/styles_app.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  String data = '';

  @override
  void initState() {
    loadFileAsset();
    super.initState();
  }

  Future<void> loadFileAsset() async {
    String textFile = '';
    try {
      String fileText = await rootBundle.loadString('assets/files/info.md');
      textFile = fileText;
    } catch (e) {
      textFile = 'Failed to load asset';
    } finally {
      setState(() {
        data = textFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: StylesApp.backgroundScreen(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text('Info')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Expanded(
                  child: MarkdownWidget(
                    data: data,
                    shrinkWrap: true,
                    config: MarkdownConfig(
                      configs: [
                        ListConfig(marginBottom: 0),
                        H2Config(
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 22,
                          ),
                        ),
                        BlockquoteConfig(textColor: Colors.white54),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
