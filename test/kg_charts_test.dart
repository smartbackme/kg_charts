import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kg_charts/kg_charts.dart';

void main() {
  test('RadarWidget test', () {
    final radarWidget = RadarWidget(
      skewing: 0,
      radarMap: RadarMapModel(
        legend: [
          LegendModel('10/10', const Color(0XFF0EBD8D)),
          LegendModel('10/11', const Color(0XFFEAA035)),
        ],
        indicator: [
          IndicatorModel("English", 100),
          IndicatorModel("Physics", 100),
          IndicatorModel("Chemistry", 100),
          IndicatorModel("Biology", 100),
          IndicatorModel("Politics", 100),
          IndicatorModel("History", 100),
        ],
        data: [
          //   MapDataModel([48,32.04,1.00,94.5,19,60,50,30,19,60,50]),
          //   MapDataModel([42.59,34.04,1.10,68,99,30,19,60,50,19,30]),
          MapDataModel([100, 90, 90, 90, 10, 20]),
          MapDataModel([90, 90, 90, 90, 10, 20]),
        ],
        radius: 130,
        duration: 2000,
        shape: Shape.square,
        maxWidth: 70,
        line: LineModel(4),
      ),
      textStyle: const TextStyle(color: Colors.black, fontSize: 14),
      isNeedDrawLegend: true,
      lineText: (p, length) => "${(p * 100 ~/ length)}%",
      dilogText: (IndicatorModel indicatorModel, List<LegendModel> legendModels,
          List<double> mapDataModels) {
        StringBuffer text = StringBuffer("");
        for (int i = 0; i < mapDataModels.length; i++) {
          text.write(
              "${legendModels[i].name} : ${mapDataModels[i].toString()}");
          if (i != mapDataModels.length - 1) {
            text.write("\n");
          }
        }
        return text.toString();
      },
      outLineText: (data, max) => "${data * 100 ~/ max}%",
    );
    expect(radarWidget.skewing, 0);
  });
}
