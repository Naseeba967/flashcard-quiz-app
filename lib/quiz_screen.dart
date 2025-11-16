// screens/quiz_screen.dart
import 'package:codealpha_flashcardquizapp/provider/flash_card_provider.dart';
import 'package:codealpha_flashcardquizapp/widget/add_edit_flashcard_dialog.dart';
import 'package:codealpha_flashcardquizapp/widget/flash_card_action.dart';
import 'package:codealpha_flashcardquizapp/widget/flash_card_navigation.dart';
import 'package:codealpha_flashcardquizapp/widget/flash_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlashCardProvider>().initialize();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddDialog(BuildContext context) async {
    try {
      final result = await showDialog<Map<String, String>>(
        context: context,
        builder: (context) => const AddEditFlashcardDialog(),
      );

      if (result != null && mounted) {
        await context.read<FlashCardProvider>().addFlashCard(
          result['question']!,
          result['answer']!,
        );
        _showSnackBar('Flashcard added successfully!');
      }
    } catch (e) {
      _showSnackBar('Failed to add flashcard: $e', isError: true);
    }
  }

  void _showEditDialog(BuildContext context) async {
    try {
      final provider = context.read<FlashCardProvider>();
      final currentCard = provider.currentCard;

      if (currentCard == null) {
        _showSnackBar('No flashcard to edit', isError: true);
        return;
      }

      final result = await showDialog<Map<String, String>>(
        context: context,
        builder: (context) => AddEditFlashcardDialog(
          initialQuestion: currentCard.question,
          initialAnswer: currentCard.answer,
          isEidit: true,
        ),
      );

      if (result != null && mounted) {
        await provider.editFlashCard(
          currentCard.id,
          result['question']!,
          result['answer']!,
        );
        _showSnackBar('Flashcard updated successfully!');
      }
    } catch (e) {
      _showSnackBar('Failed to update flashcard: $e', isError: true);
    }
  }

  void _deleteCurrentCard(BuildContext context) async {
    try {
      final provider = context.read<FlashCardProvider>();
      final currentCard = provider.currentCard;

      if (currentCard == null) {
        _showSnackBar('No flashcard to delete', isError: true);
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Text('Delete Flashcard'),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this flashcard? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        await provider.deleteFlashCard(currentCard.id);
        _showSnackBar('Flashcard deleted successfully!');
      }
    } catch (e) {
      _showSnackBar('Failed to delete flashcard: $e', isError: true);
    }
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.blue),
              title: const Text('Reset to First Card'),
              onTap: () {
                context.read<FlashCardProvider>().reset();
                Navigator.pop(context);
                _showSnackBar('Reset to first card');
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.orange),
              title: const Text('Reset to Default Cards'),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset to Default'),
                    content: const Text(
                      'This will delete all your cards and restore the default ones.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  await context.read<FlashCardProvider>().resetToDefault();
                  _showSnackBar('Reset to default cards');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color lightBackgroundColor = Color(0xFFF7F9FC);

    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: lightBackgroundColor,
        centerTitle: true,
        title: const Text(
          'FlashCard Quiz',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: Consumer<FlashCardProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Loading your flashcards...'),
                ],
              ),
            );
          }

          // Empty state
          if (provider.flashcards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  const Text(
                    'No flashcards yet!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Create your first flashcard to get started',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Flashcard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Main content
          return SingleChildScrollView(
            child: Column(
              children: [
                // Progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: (provider.currentIndex + 1) / provider.totalCard,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Card ${provider.currentIndex + 1} of ${provider.totalCard}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _showAddDialog(context),
                        child: const FlashCardAction(
                          text: 'Add',
                          color: Colors.green,
                          icon: Icons.add,
                        ),
                      ),
                      const SizedBox(width: 7),
                      GestureDetector(
                        onTap: () => _showEditDialog(context),
                        child: const FlashCardAction(
                          text: 'Edit',
                          color: Colors.orange,
                          icon: Icons.edit,
                        ),
                      ),
                      const SizedBox(width: 7),
                      GestureDetector(
                        onTap: () => _deleteCurrentCard(context),
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Flashcard
                FlashCardWidget(
                  question: provider.currentCard!.question,
                  answer: provider.currentCard!.answer,
                  showAnswer: provider.showAnswer,
                ),

                const SizedBox(height: 20),

                // Show/Hide answer button
                ElevatedButton(
                  onPressed: provider.toggleAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        provider.showAnswer
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.showAnswer ? 'Hide Answer' : 'Show Answer',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Opacity(
                        opacity: provider.goToPrevious ? 1.0 : 0.5,
                        child: FlashCardNavigation(
                          text: 'Previous',
                          onPressed: provider.goToPrevious
                              ? () => provider.previousCard()
                              : null,
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                      Opacity(
                        opacity: provider.goToNext ? 1.0 : 0.5,
                        child: FlashCardNavigation(
                          text: 'Next',
                          onPressed: provider.goToNext
                              ? () => provider.nextCard()
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
