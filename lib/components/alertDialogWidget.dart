import 'package:flutter/material.dart';

class AlertDialogWidget extends StatefulWidget {
  const AlertDialogWidget({super.key});

  @override
  State<AlertDialogWidget> createState() => _AlertDialogWidgetState();
}

class _AlertDialogWidgetState extends State<AlertDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton (
        child: const Text('Show Alert Dialog'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                 child: const Text('Close')
                ),
              ],
              title : const Text('Alert Dialog'),
              contentPadding: const EdgeInsets.all(20.0),
              content: const Text('This is the Alert Dialog')
            )
          );
        }
      )
    );
  }
}