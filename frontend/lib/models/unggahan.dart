class Unggahan {
  final int? id;
  final String userName;
  final String usernameHandle;
  final String? userAvatar;
  final String placeName;
  final int rating;
  final String address;
  final String review;
  final String budget;
  final List<String> imagePaths;

  Unggahan({
    this.id,
    required this.userName,
    required this.usernameHandle,
    this.userAvatar,
    required this.placeName,
    required this.rating,
    required this.address,
    required this.review,
    required this.budget,
    required this.imagePaths,
  });

  factory Unggahan.fromJson(Map<String, dynamic> json) {
    return Unggahan(
      id:              json['id'] as int?,
      userName:        json['userName'] as String,
      usernameHandle:  json['usernameHandle'] as String,
      userAvatar:      json['userAvatar'] as String?,
      placeName:       json['placeName'] as String,
      rating:          json['rating'] as int,
      address:         json['address'] as String,
      review:          json['review'] as String,
      budget:          json['budget'] as String,
      imagePaths:      List<String>.from(json['imagePaths'] as List),
    );
  }
}

final List<Unggahan> dummyUnggahans = [
  Unggahan(
    userName: "Wawanti",
    usernameHandle: "@wawanti001",
    userAvatar: "W",
    placeName: "Bahasa Alam BSD",
    rating: 4,
    address: "The Green, Cluster Manhattan B7/17 BSD City, Cilenggang, Kec. Serpong, Kota Tangerang Selatan, Banten 15310",
    review: "Makanan dan minumannya enak, manteppp dah pokoknyaaa... Harga juga okes... Ambiencenya gak kalah mantep, tenang dan ademmm...",
    budget: "Rp 50k - Rp 100k",
    imagePaths: [],
  ),
  Unggahan(
    userName: "Richard",
    usernameHandle: "@user71726",
    userAvatar: "R",
    placeName: "Hygge Cafe BSD",
    rating: 4,
    address: "Jl. BSD Grand Boulevard, Sampora, Kec. Cisauk, Kabupaten Tangerang, Banten 15345",
    review: "Favourite spot to go buat WFC dan ngeliatin pemandangan. Makanannya not bad and there are lots of options. Plenty of beverages options too. Servicenya lumayan, around 20 menit udah dateng makanannya. Definitely will go back here :)",
    budget: "Rp 50k - Rp 100k",
    imagePaths: [],
  ),
  Unggahan(
    userName: "Sabine",
    usernameHandle: "@vi_enrose9",
    userAvatar: "S",
    placeName: "Bear&Butter BSD",
    rating: 5,
    address: "Mall Ararasa BSD, Lantai Unit GC, Lengkong Kulon, Kec. Pagedangan, Kabupaten Tangerang, Banten 15331",
    review: "Kafenya lucu, estetik, dan mewah yang aku temukan dekat rumah. Mereka menyajikan kopi yang enak dan berbagai varian salt bread dengan rasa yang lezat.",
    budget: "Rp 50k - Rp 100k",
    imagePaths: [],
  ),
  Unggahan(
    userName: "Kaatiya",
    usernameHandle: "@aim2love",
    userAvatar: "K",
    placeName: "Artirasa Gading Serpong",
    rating: 5,
    address: "Ruko, Jl. Goldfinch Raya Jl. Springs Boulevard.31, Blok SGD No.30, Kabupaten Tangerang, Banten 15810",
    review: "menurutku enak, tapi bukan yang enak banget. yang jelas menurutku masih best menu cheesecakenya 🫶🏻",
    budget: "Rp 1k - Rp 50k",
    imagePaths: [],
  ),
  Unggahan(
    userName: "Sanca Jill",
    usernameHandle: "@kitticatto",
    userAvatar: "SJ",
    placeName: "Salt Bread from Seoul BSD",
    rating: 4,
    address: "PJ7G+473 Zena at The Mozia M5, Jl. Lkr. Botanika Selatan No.1, Lengkong Kulon, Pagedangan, BSD City, Banten 15331",
    review: "Salah satu salt bread terenak yang udah aku coba! Luarnya crunchy dalemnya lembut. Untuk varian original bener-bener kerasa butternya dan crunchy bagian luarnya. Yang korean fried chicken enggak kalah enak tapi agak sedikit terlalu asin menurut lidahku, tapi kembali ke selera masing-masing. Favorit aku varian manis, milkeu way. Bener-bener kerasa susunya dan creamnya juga enggak bikin enek, tapi tetep kerasa crunchy dan buttery dari salt breadnya. Gak cukup kayaknya berkunjung sekali, will be repurchasing!",
    budget: "Rp 1k - Rp 50k",
    imagePaths: [],
  ),
];
