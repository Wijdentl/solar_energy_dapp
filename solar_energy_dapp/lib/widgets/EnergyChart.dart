import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:solar_energy_dapp/ethereum_service.dart';
import 'package:solar_energy_dapp/side_menu.dart';
class EnergyChartPage extends StatelessWidget {
  final double superConsumptionThreshold = 100; // Définir un seuil de superconsommation

  @override
  Widget build(BuildContext context) {
    final contractLinking = Provider.of<ContractLinking>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Energy Production & Consumption"),
      ),
      body: FutureBuilder<Map<String, List<BigInt>>>(
        future: contractLinking.getEnergyDataForGraph(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No data available"),
            );
          }

          final data = snapshot.data!;
          final productionData = data['production'] ?? [];
          final consumptionData = data['consumption'] ?? [];
          final timestamps = data['timestamps'] ?? [];

          // Vérifiez si les données sont vides
          if (productionData.isEmpty && consumptionData.isEmpty) {
            return const Center(
              child: Text("Aucune donnée d'énergie disponible."),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _buildLegend(),
                Container(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitles: (value) => value.toInt().toString(),
                        ),
                        bottomTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitles: (value) {
                            final index = value.toInt();
                            if (index >= 0 && index < timestamps.length) {
                              final timestamp = DateTime.fromMillisecondsSinceEpoch(
                                  timestamps[index].toInt() * 1000);
                              return "${timestamp.day}/${timestamp.month}";
                            }
                            return '';
                          },
                          interval: 1,
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      minX: 0,
                      maxX: (timestamps.length - 1).toDouble(),
                      minY: 0,
                      maxY: _getMaxValue(productionData, consumptionData),
                      lineBarsData: [
                        LineChartBarData(
                          spots: productionData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final value = entry.value.toDouble();
                            return FlSpot(index.toDouble(), value);
                          }).toList(),
                          isCurved: true,
                          colors: [Colors.green],
                          barWidth: 4,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(show: false),
                          dotData: FlDotData(show: true),
                        ),
                        LineChartBarData(
                          spots: consumptionData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final value = entry.value.toDouble();
                            return FlSpot(index.toDouble(), value);
                          }).toList(),
                          isCurved: true,
                          colors: [Colors.red],
                          barWidth: 4,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(show: false),
                          dotData: FlDotData(show: true),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                ),
                // Afficher un message si la superconsommation est détectée
                if (_isSuperConsumption(consumptionData))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Alerte : Superconsommation détectée !",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isSuperConsumption(List<BigInt> consumptionData) {
    return consumptionData.any((value) => value.toDouble() > superConsumptionThreshold);
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(Colors.green, "Production"),
        _buildLegendItem(Colors.red, "Consommation"),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  double _getMaxValue(List<BigInt> production, List<BigInt> consumption) {
    final productionMax = production.map((e) => e.toDouble()).reduce((a, b) => a > b ? a : b);
    final consumptionMax = consumption.map((e) => e.toDouble()).reduce((a, b) => a > b ? a : b);
    return (productionMax > consumptionMax ? productionMax : consumptionMax) * 1.1;
  }
}
