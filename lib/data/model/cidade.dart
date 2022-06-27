class Cidade {
  final String id;
  final String nome;
  final String IdEstado;

  Cidade({
    required this.id,
    required this.nome,
    required this.IdEstado,
  });

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
        id: json['id'],
        nome: json['nome'],
        IdEstado: json['microrregiao']['mesorregiao']['UF']['id']);
  }
}
