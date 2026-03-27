class Company {
  final String id;
  final String userId;
  final String name;
  final String sector;
  final String hrSorumlusu;
  final String webSite;

  Company({
    required this.id,
    required this.userId,
    required this.name,
    required this.sector,
    required this.hrSorumlusu,
    required this.webSite,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'ad': name,
      'sektor': sector,
      'ik_sorumlusu': hrSorumlusu,
      'web_sitesi': webSite,
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['ad'] ?? '',
      sector: map['sektor'] ?? '',
      hrSorumlusu: map['ik_sorumlusu'] ?? '',
      webSite: map['web_sitesi'] ?? '',
    );
  }
}
