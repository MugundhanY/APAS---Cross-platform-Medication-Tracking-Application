import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// ignore: must_be_immutable
class ToDoTile extends StatelessWidget {
  final String taskName;

  //final bool taskCompleted;
  final String timerr;

  //Function(bool?)? onChanged;
  Function(BuildContext)? deleteFunction;

  ToDoTile({
    super.key,
    required this.taskName,
    //required this.taskCompleted,
    required this.timerr,
    // required this.onChanged,
    required this.deleteFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25, top: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red.shade700,
              borderRadius: BorderRadius.circular(12),
            )
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 68, 243, 168),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // checkbox
              /*Checkbox(
                value: taskCompleted,
                onChanged: onChanged,
                activeColor: Colors.black,
              ),*/

              // task name
              Text(
                taskName,
                style: const TextStyle(
                  decoration: //taskCompleted
                      //? TextDecoration.lineThrough
                      //:
                      TextDecoration.none,
                ),
              ),
              Text(
                timerr,
                style: const TextStyle(
                  decoration: //taskCompleted
                      //? TextDecoration.lineThrough
                      //:
                      TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
