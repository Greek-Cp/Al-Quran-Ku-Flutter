class Doa {
  String? id;
  String? doa;
  String? ayat;
  String? latin;
  String? artinya;

  Doa({this.id, this.doa, this.ayat, this.latin, this.artinya});

  Doa.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doa = json['doa'];
    ayat = json['ayat'];
    latin = json['latin'];
    artinya = json['artinya'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['doa'] = this.doa;
    data['ayat'] = this.ayat;
    data['latin'] = this.latin;
    data['artinya'] = this.artinya;
    return data;
  }
}
