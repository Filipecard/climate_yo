class Estado {
  final int id;
  final String sigla;
  final String nome;
  final String regiao;

  Estado({
    required this.id,
    required this.sigla,
    required this.nome,
    required this.regiao,
  });

  factory Estado.fromJson(Map<String, dynamic> json) {
    return Estado(
        id: json['id'],
        sigla: json['sigla'],
        nome: json['nome'],
        regiao: json['regiao']['nome']);
  }
}
