class UserDetailsModel {
  final String name;

  UserDetailsModel({required this.name});

  Map<String, dynamic> getJson() => {
        'name': name,
      };

  factory UserDetailsModel.getModelFromJson(Map<String, dynamic> json) {
    return UserDetailsModel(name: json["name"]);
  }
}
