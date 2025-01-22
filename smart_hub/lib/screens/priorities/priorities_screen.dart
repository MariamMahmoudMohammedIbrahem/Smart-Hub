import '../../commons.dart';

part 'priorities_controller.dart';

class PrioritiesScreen extends StatefulWidget {
  static String id = 'priorities_screen';
  const PrioritiesScreen({super.key});

  @override
  createState() => _PrioritiesScreen();
}

class _PrioritiesScreen extends PrioritiesController {
  @override
  Widget build(BuildContext context) {
    final screenDataProvider = Provider.of<ScreenDataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Power Settings', style: TextStyle(fontWeight: FontWeight.bold,),),
        centerTitle: true,
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),  // Bottom left corner rounded
            bottomRight: Radius.circular(15), // Bottom right corner rounded
          ),
          child: Container(
            color: screenDataProvider.isThemeDark ? Colors.black26 : Colors.indigo,
          ),
        ),
      ),
      backgroundColor:
      screenDataProvider.isThemeDark ? Colors.grey[900] : Colors.white,
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1; // Adjust for index shift caused by the reorder.
            }
            final entry = entries.removeAt(oldIndex);
            entries.insert(newIndex, entry);
            print(entries);
          });
        },
        children: entries.map((entry) {
          return ListTile(
            key: entry.key,
            title: entry.value,
          );
        }).toList(),
      ),
    );
  }
}