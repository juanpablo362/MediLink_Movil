import 'package:material_ui/material_ui.dart';

class EnConstruccionPage extends StatelessWidget {
  const EnConstruccionPage({super.key, this.conRegreso = false});

  final bool conRegreso;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: conRegreso
          ? AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
            )
          : null,
      body: const Center(child: Text('En construcción')),
    );
  }
}
