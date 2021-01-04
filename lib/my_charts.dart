import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

final List<Color> gradientColors = [
  const Color(0xff448aff),
  const Color(0xffe1f5f2),
  const Color(0xff448aff),
];

DateTime date = DateTime.now();

LineChartBarData lineChartBarData = LineChartBarData();

class MyLineChart extends StatelessWidget {
  MyLineChart(
      {this.maximumX,
      this.maximumY,
      this.minimumX,
      this.minimumY,
      this.spots,
      this.currency1,
      this.graphValue});
  final double minimumX;
  final double maximumX;
  final double minimumY;
  final double maximumY;
  final String currency1;

  final num graphValue;

  final List<FlSpot> spots;
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        padding: EdgeInsets.only(left: 40, right: 40, top: 40),
        child: LineChart(
          LineChartData(
              titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTextStyles: (value) => const TextStyle(
                        color: Color(0xffffffff),
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                    getTitles: (value) {
                      switch (value.toInt()) {
                        case 3:
                          return '${DateFormat.MMMd().format(date.subtract(Duration(days: graphValue.toInt() - 3)))}';
                        case 9:
                          return '${DateFormat.MMMd().format(date.subtract(Duration(days: graphValue.toInt() - 9)))}';
                        case 16:
                          return '${DateFormat.MMMd().format(date.subtract(Duration(days: graphValue.toInt() - 16)))}';
                        case 23:
                          return '${DateFormat.MMMd().format(date.subtract(Duration(days: graphValue.toInt() - 23)))}';
                        case 29:
                          return '${DateFormat.MMMd().format(date.subtract(Duration(days: graphValue.toInt() - 29)))}';
                      }
                      return '';
                    },
                    margin: 8,
                  ),
                  leftTitles: SideTitles(showTitles: false)),
              gridData: FlGridData(show: false),
              minX: minimumX,
              maxX: maximumX,
              minY: minimumY,
              maxY: maximumY,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Color(0xff00e676),
                    getTooltipItems: (spots) {
                      List<LineTooltipItem> toolTips = [];
                      for (var i in spots) {
                        toolTips.add(LineTooltipItem(
                            '${DateFormat.MMMd().format(date.subtract(Duration(days: graphValue.toInt() - i.x.toInt())))} \n1 $currency1 = ${i.y.toStringAsFixed(3)}',
                            TextStyle(color: Colors.white, fontSize: 13)));
                      }
                      return toolTips;
                    }),
              ),
              borderData: FlBorderData(
                  show: true,
                  border: Border(
                      bottom: BorderSide(
                          style: BorderStyle.solid, color: Colors.white))),
              lineBarsData: [
                LineChartBarData(
                  show: true,
                  isCurved: true,
                  barWidth: 0.1,
                  colors: [Colors.transparent],
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(show: true, colors: gradientColors),
                  dotData: FlDotData(
                    show: false,
                  ),
                  spots: spots,
                ),
              ]),
        ),
      ),
    );
  }
}
