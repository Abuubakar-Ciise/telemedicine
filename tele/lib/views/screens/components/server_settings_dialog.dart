import 'package:flutter/material.dart';
import 'package:tele/views/screens/components/config.dart';

/// Lets testers point the app at a different backend (e.g. the PC's IPv4
/// address on the local Wi-Fi) without rebuilding the app.
Future<void> showServerSettingsDialog(BuildContext context) {
  return showDialog(context: context, builder: (_) => const _ServerSettingsDialog());
}

class _ServerSettingsDialog extends StatefulWidget {
  const _ServerSettingsDialog();

  @override
  State<_ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<_ServerSettingsDialog> {
  late final TextEditingController _controller = TextEditingController(text: Config.baseUrl);
  bool _testing = false;
  String? _result;
  bool _ok = false;

  static const _green = Color.fromARGB(255, 9, 130, 13);

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _result = null;
    });
    final error = await Config.testServer(_controller.text);
    if (!mounted) return;
    setState(() {
      _testing = false;
      _ok = error == null;
      _result = error ?? 'Connected to ${Config.normalizeUrl(_controller.text)}';
    });
  }

  Future<void> _save() async {
    await Config.setServerUrl(_controller.text);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server set to ${Config.baseUrl}')));
  }

  Future<void> _reset() async {
    await Config.setServerUrl(null);
    if (!mounted) return;
    setState(() {
      _controller.text = Config.baseUrl;
      _result = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Server settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Address of the Telemedicine backend. Use your computer\'s IPv4 address '
              '(run "ipconfig" on the PC) and keep the phone on the same Wi-Fi.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'API address',
                hintText: 'http://192.168.100.8:2003',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() => _result = null),
            ),
            const SizedBox(height: 8),
            Text('Default from .env: ${Config.defaultBaseUrl}', style: const TextStyle(fontSize: 12, color: Colors.black45)),
            if (_result != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_ok ? Icons.check_circle : Icons.error, size: 18, color: _ok ? _green : Colors.red),
                  const SizedBox(width: 6),
                  Expanded(child: Text(_result!, style: TextStyle(fontSize: 13, color: _ok ? _green : Colors.red))),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _reset, child: const Text('Use default')),
        TextButton(
          onPressed: _testing ? null : _test,
          child: _testing
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Test connection'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _green),
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
