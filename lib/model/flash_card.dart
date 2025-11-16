class FlashCard {
  String id;
  final String question;
  final String answer;

  FlashCard({required this.question, required this.id, required this.answer});
  Map<String, dynamic> toJson() {
    return {'id': id, 'question': question, 'answer': answer};
  }

  factory FlashCard.fromJson(Map<String, dynamic> json) {
    return FlashCard(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
    );
  }
}
