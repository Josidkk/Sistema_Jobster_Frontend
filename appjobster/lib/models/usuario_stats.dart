class UsuarioStats {
  final int totalAprobados;
  final int totalUsuarios;

  UsuarioStats({
    required this.totalAprobados,
    this.totalUsuarios = 0,
  });

  factory UsuarioStats.fromJson(Map<String, dynamic> json) {
    return UsuarioStats(
      totalAprobados: json['TotalAprobados'] ?? 0,
    );
  }
}
