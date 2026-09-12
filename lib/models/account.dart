class Account {
  final String id;
  final String label;
  final String apiKey;

  const Account({required this.id, required this.label, required this.apiKey});

  Account copyWith({String? label, String? apiKey}) => Account(
    id: id,
    label: label ?? this.label,
    apiKey: apiKey ?? this.apiKey,
  );

  Map<String, dynamic> toJson() => {'id': id, 'label': label, 'apiKey': apiKey};

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json['id'] as String,
    label: json['label'] as String,
    apiKey: json['apiKey'] as String,
  );
}
