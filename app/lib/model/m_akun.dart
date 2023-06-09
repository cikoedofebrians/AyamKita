class MAkun {
  String id;
  String nama;
  String role;
  String email;
  String peternakanId;
  String noTelepon;
  String alamat;
  String tanggalPendaftaran;
  String downloadUrl;
  String dokterDetailsId;

  MAkun({
    required this.id,
    required this.nama,
    required this.role,
    required this.alamat,
    required this.email,
    required this.peternakanId,
    required this.dokterDetailsId,
    required this.downloadUrl,
    required this.tanggalPendaftaran,
    required this.noTelepon,
  });

  factory MAkun.fromJson(Map<String, dynamic> json, id) => MAkun(
        id: id,
        nama: json['nama'],
        role: json['role'],
        alamat: json.containsKey('alamat') ? json['alamat'] : '',
        downloadUrl: json.containsKey('downloadUrl') ? json['downloadUrl'] : '',
        email: json['email'],
        noTelepon:
            json.containsKey('noTelepon') ? json['noTelepon'].toString() : '',
        peternakanId: json['peternakanId'],
        tanggalPendaftaran: json['tanggal_pendaftaran'],
        dokterDetailsId:
            json.containsKey('dokterDetailsId') ? json['dokterDetailsId'] : '',
      );
}
