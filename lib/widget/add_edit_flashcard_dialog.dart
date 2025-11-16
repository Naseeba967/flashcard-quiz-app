import 'package:flutter/material.dart';

class AddEditFlashcardDialog extends StatefulWidget {
  final String? initialQuestion;
  final String? initialAnswer;
  final bool isEidit;

  const AddEditFlashcardDialog({
    super.key,
    this.initialAnswer,
    this.initialQuestion,
    this.isEidit = false,
  });
  @override
  State<AddEditFlashcardDialog> createState() => _AddEditFlashcardDialogState();
}

class _AddEditFlashcardDialogState extends State<AddEditFlashcardDialog> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      _questionController = TextEditingController(text: widget.initialQuestion);
      _answerController = TextEditingController(text: widget.initialAnswer);
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEidit ? 'Edit  FlashCrad ' : 'Add new FlashCard'),
      content: Form(
        key: _formKey,

        child: Column(
          children: [
            TextFormField(
              controller: _questionController,
              decoration: InputDecoration(labelText: 'Question'),
            ),
            TextFormField(
              controller: _answerController,
              decoration: InputDecoration(labelText: 'Answer'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'question': _questionController.text.trim(),
                'answer': _answerController.text.trim(),
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isEidit ? Colors.orange : Colors.green,
          ),
          child: Text(widget.isEidit ? 'update' : 'Add'),
        ),
      ],
    );
  }
}
