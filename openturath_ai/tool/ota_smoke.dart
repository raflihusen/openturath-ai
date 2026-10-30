// Local installer smoke fixture. Never a public application entry point.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() => runApp(const MaterialApp(home: OtaSmoke()));

class OtaSmoke extends StatefulWidget {
  const OtaSmoke({super.key});
  @override
  State<OtaSmoke> createState() => _OtaSmokeState();
}

class _OtaSmokeState extends State<OtaSmoke> {
  String state = 'Loading';
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => state = 'OTA smoke build ${info.buildNumber}');
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(state),
        FilledButton(
            onPressed: () async {
              try {
                final result =
                    await const MethodChannel('com.openturath.ai/updater')
                        .invokeMethod<String>('install', {
                  'path':
                      '/data/user/0/com.openturath.ai/files/updates/candidate.apk',
                  'build': 88
                });
                if (mounted) setState(() => state = '$result');
              } catch (e) {
                if (mounted) setState(() => state = 'Rejected: $e');
              }
            },
            child: const Text('Install local fixture')),
      ])));
}
