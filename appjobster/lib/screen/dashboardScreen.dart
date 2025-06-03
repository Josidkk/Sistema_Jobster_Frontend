import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/top_plaza.dart';
import '../models/usuario_stats.dart';
import '../services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TopPlaza> _topPlazas = [];
  UsuarioStats? _usuarioStats;
  bool _isLoadingPlazas = true;
  bool _isLoadingUsuarios = true;
  String _errorPlazas = '';
  String _errorUsuarios = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    _cargarPlazas();
    _cargarUsuarios();
  }

  Future<void> _cargarPlazas() async {
    try {
      final plazas = await DashboardService.getTop5Plazas();
      setState(() {
        _topPlazas = plazas;
        _isLoadingPlazas = false;
      });
    } catch (e) {
      setState(() {
        _errorPlazas = e.toString();
        _isLoadingPlazas = false;
      });
    }
  }

  Future<void> _cargarUsuarios() async {
    try {
      final stats = await DashboardService.getUsuariosAprobados();
      setState(() {
        _usuarioStats = stats;
        _isLoadingUsuarios = false;
      });
    } catch (e) {
      setState(() {
        _errorUsuarios = e.toString();
        _isLoadingUsuarios = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard de Jobster',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Usuarios Aprobados Card
              _buildUsuariosAprobadosCard(),
              const SizedBox(height: 30),
              
              // Top 5 Plazas
              const Text(
                'Top 5 Plazas Más Solicitadas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 400, // Altura fija para el gráfico de barras
                child: _isLoadingPlazas 
                  ? const Center(child: CircularProgressIndicator())
                  : _errorPlazas.isNotEmpty
                    ? Center(child: Text('Error: $_errorPlazas', style: TextStyle(color: Colors.red)))
                    : _topPlazas.isEmpty
                      ? const Center(child: Text('No hay datos disponibles'))
                      : Column(
                          children: [
                            Expanded(
                              child: _buildBarChart(),
                            ),
                            const SizedBox(height: 20),
                            _buildLegend(),
                          ],
                        ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsuariosAprobadosCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B00), Color(0xFFEE4D00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.people_alt_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  'Usuarios en la Plataforma',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoadingUsuarios
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _errorUsuarios.isNotEmpty
                    ? Center(
                        child: Text(
                          'Error: $_errorUsuarios',
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    : Row(
                        children: [
                          _buildUsuarioCounter(
                            title: 'Total Usuarios',
                            count: _usuarioStats?.totalUsuarios ?? 0,
                            icon: Icons.people,
                          ),
                          Container(
                            height: 50,
                            width: 1,
                            color: Colors.white.withOpacity(0.5),
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                          ),
                          _buildUsuarioCounter(
                            title: 'Usuarios Aprobados',
                            count: _usuarioStats?.totalAprobados ?? 0,
                            icon: Icons.verified_user,
                          ),
                        ],
                      ),
            const SizedBox(height: 20),
            _isLoadingUsuarios
                ? const SizedBox()
                : _errorUsuarios.isNotEmpty
                    ? const SizedBox()
                    : SizedBox(
                        height: 140,
                        child: _buildPieChart(),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsuarioCounter({
    required String title,
    required int count,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    int totalUsuarios = _usuarioStats?.totalUsuarios ?? 0;
    int totalAprobados = _usuarioStats?.totalAprobados ?? 0;
    int noAprobados = totalUsuarios - totalAprobados;
    
    // Aseguramos que no sea negativo
    noAprobados = noAprobados < 0 ? 0 : noAprobados;
    
    double porcentajeAprobados = totalUsuarios > 0 ? 
      (totalAprobados / totalUsuarios) * 100 : 0;
    
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 30,
                    sections: [
                      PieChartSectionData(
                        color: Colors.white,
                        value: totalAprobados.toDouble(),
                        title: '${porcentajeAprobados.toStringAsFixed(0)}%',
                        radius: 25,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B00),
                        ),
                      ),
                      PieChartSectionData(
                        color: Colors.white.withOpacity(0.3),
                        value: noAprobados.toDouble() == 0 ? 1 : noAprobados.toDouble(),
                        title: '',
                        radius: 25,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(
                    color: Colors.white, 
                    text: 'Aprobados',
                    value: totalAprobados,
                    percentage: porcentajeAprobados,
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                    color: Colors.white.withOpacity(0.3), 
                    text: 'Pendientes',
                    value: noAprobados,
                    percentage: 100 - porcentajeAprobados,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color, 
    required String text, 
    required int value,
    required double percentage,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$text: $value (${percentage.toStringAsFixed(0)}%)',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxValue(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final plaza = _topPlazas[groupIndex];
              return BarTooltipItem(
                '${plaza.descripcion}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${plaza.totalSolicitudes} solicitudes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value >= 0 && value < _topPlazas.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${value.toInt() + 1}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _buildBarGroups(),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return _topPlazas.asMap().entries.map((entry) {
      final index = entry.key;
      final plaza = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: plaza.totalSolicitudes.toDouble(),
            color: _getColorByIndex(index),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getColorByIndex(int index) {
    List<Color> colors = [
      const Color(0xFFFF6B00), // Naranja de Jobster
      const Color(0xFFE64A19),
      const Color(0xFFD84315),
      const Color(0xFFBF360C),
      const Color(0xFF9E2A0B),
    ];
    
    return index < colors.length ? colors[index] : colors.last;
  }

  double _getMaxValue() {
    if (_topPlazas.isEmpty) return 10;
    double max = _topPlazas
        .map((plaza) => plaza.totalSolicitudes)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    return max + (max * 0.2);
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _topPlazas.asMap().entries.map((entry) {
          final index = entry.key;
          final plaza = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _getColorByIndex(index),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${index + 1}. ${plaza.descripcion}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${plaza.totalSolicitudes} solicitudes',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ], 
            ),
          );
        }).toList(),
      ),
    );
  }
}
