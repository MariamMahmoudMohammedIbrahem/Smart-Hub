import '../../commons.dart';

part 'support_controller.dart';

class SupportScreen extends StatefulWidget {
  static String id = 'support_screen';
  const SupportScreen({super.key});

  @override
  createState() => _SupportScreen();
}

class _SupportScreen extends SupportController {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Support'),
        ),
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'Support Screen',
              ),
            ),
          ],
        ),
      ),
    );
  }
}