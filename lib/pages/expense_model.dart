// Definition of an Expense
class Expense {
   int? id; // DB ID
  final String name;     
  final double amount;    
  final String category;  
  final DateTime date;
  final String details;

  Expense({
    this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
    required this.details,
  });

//convert object to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'details': details,
    };
  }

  //convert DB record to object
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      details: map['details'],
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
  return Expense(
    name: json['name'],
    amount: json['amount'],
    category: json['category'],
    date: DateTime.parse(json['date']),
    details: json['details'],
  );
}

}
