class Climate {
  final int temperatura;
  final String data;
  final String hora;
  final String descricao;
  final int humidade;
  final String velVento;

  Climate({
    required this.temperatura,
    required this.data,
    required this.hora,
    required this.descricao,
    required this.humidade,
    required this.velVento,
  });

  factory Climate.fromJson(Map<String, dynamic> json) {
    return Climate(
      temperatura: json['results']['temp'],
      data: json['results']['date'],
      hora: json['results']['time'],
      descricao: json['results']['description'],
      humidade: json['results']['humidity'],
      velVento: json['results']['wind_speedy'],
    );
  }
}
