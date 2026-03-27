import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final user = authService.currentUser;

    if (user == null) return const Center(child: Text('Giriş yapılmadı'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Merhaba, ${user.displayName?.split(' ').first ?? 'Aday'}!',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Kariyer yolculuğunda bugün neler var?',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 32),
          
          // İstatistik Kartları
          FutureBuilder<Map<String, int>>(
            future: firestoreService.getStats(user.uid),
            builder: (context, snapshot) {
              final stats = snapshot.data ?? {};
              return Row(
                children: [
                  _buildStatCard('Toplam', '${stats.values.fold(0, (a, b) => a + b)}', Colors.blueAccent),
                  const SizedBox(width: 16),
                  _buildStatCard('Mülakat', '${stats['Mülakat'] ?? 0}', const Color(0xFFE8FF47), textColor: Colors.black),
                ],
              );
            },
          ),
          
          const SizedBox(height: 32),
          const Text('Haftalık Yoğunluk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          
          // Grafik
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                       FlSpot(0, 1),
                       FlSpot(1, 4),
                       FlSpot(2, 2),
                       FlSpot(3, 5),
                       FlSpot(4, 3),
                       FlSpot(5, 7),
                       FlSpot(6, 4),
                    ],
                    isCurved: true,
                    color: const Color(0xFFE8FF47),
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFE8FF47).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, {Color textColor = Colors.white}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color == const Color(0xFFE8FF47) ? color : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: color == const Color(0xFFE8FF47) ? null : Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
