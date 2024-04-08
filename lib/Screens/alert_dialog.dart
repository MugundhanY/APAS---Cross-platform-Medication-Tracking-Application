import 'package:flutter/material.dart';
import 'package:hackathon_project/List/my_button.dart';
import 'package:hackathon_project/constants/color_theme.dart';

class alertDialog extends StatelessWidget{
  final medicineNamecontroller;

  // ignore: prefer_typing_uninitialized_variables, non_constant_identifier_names
  final dosageTimeController;
  VoidCallback onSave;
  VoidCallback onCancel;

  alertDialog({
    super.key,
    required this.medicineNamecontroller,
    // ignore: non_constant_identifier_names
    required this.dosageTimeController,
    required this.onSave,
    required this.onCancel,
  });

  /*void _showMedicineDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Medicine Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: medicineNameController,
                decoration: InputDecoration(
                  labelText: 'Medicine Name',
                ),
              ),
              TextField(
                controller: dosageTimeController,
                decoration: InputDecoration(
                  labelText: 'Dosage Time',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Save button logic
                String medicineName = medicineNameController.text;
                String dosageTime = dosageTimeController.text;

                // Do something with the entered data
                // For example, print it
                print('Medicine Name: $medicineName');
                print('Dosage Time: $dosageTime');

                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                // Cancel button logic
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Dialog'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showMedicineDialog,
          child: Text('Open Dialog'),
        ),
      ),
    );
  }
}

   */
Widget build(BuildContext context) {
  return AlertDialog(
    backgroundColor: combinedColor,
    content: SizedBox(
      height: 240,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // get user input
          TextField(
            controller: medicineNamecontroller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Add a medicine name",
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          TextField(
            controller: dosageTimeController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Add a dosage time",
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          // buttons -> save + cancel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // save button
              MyButton(
                text: "Cancel",
                onPressed: onCancel,
                col: Colors.redAccent,
              ),
              const SizedBox(width: 8),
              MyButton(
                text: "Save",
                onPressed: onSave,
                col: Color.fromARGB(255, 68, 243, 168),
              ),

              // cancel button
            ],
          ),
        ],
      ),
    ),
  );
}
}