class SpendingModel {
  int? spending_id;
  num? spending_amount;
  String? spending_type;
  int? spending_category;
  String? spending_date;

  SpendingModel({
    this.spending_id,
    required this.spending_amount,
    required this.spending_type,
    required this.spending_category,
    required this.spending_date,
  });
  factory SpendingModel.fromMap({required Map<String, dynamic> data}) {
    return SpendingModel(
      spending_id: data['spending_id'],
      spending_amount: data['spending_amount'],
      spending_type: data['spending_type'],
      spending_category: data['spending_category'],
      spending_date: data['spending_date'],
    );
  }
}
