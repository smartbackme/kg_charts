import 'package:flutter/material.dart';
import 'package:kg_charts/kg_charts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          alignment: AlignmentDirectional.center,
          child: RadarWidget(
            skewing: 0,
            isNeedDrawLegend: true,
            isNeedDrawVisualMap: true,
            radarMap: RadarMapModel(
              alpha: 200,
              // legend: [
              //   LegendModel('Low', HexColor('#EDEEEE')),
              //   // LegendModel('Low', HexColor('#CEE8EA')),
              //   LegendModel('Decreased', HexColor('#CEE8EA')),
              //   // LegendModel('Normal', HexColor('#6EC9D1')),
              //   LegendModel('Normal', HexColor('#6EC9D1')),
              //   // LegendModel('High', Colors.green),
              // ],
              splitAreaStyle: SplitAreaStyle(
                colors: [
                  HexColor('#EDEEEE'),
                  HexColor('#CEE8EA'),
                  HexColor('#A9DDE1'),
                  HexColor('#6EC9D1'),
                ],
                alpha: 255,
              ),
              visualMap: VisualMap(colors: [
                HexColor('#EDEEEE'),
                HexColor('#CEE8EA'),
                HexColor('#A9DDE1'),
                HexColor('#6EC9D1'),
              ], texts: [
                'Low',
                'Normal'
              ]),
              indicator: [
                IndicatorModel("English", 4),
                IndicatorModel("Physics", 4),
                IndicatorModel("Chemistry", 4),
                IndicatorModel("Biology", 4),
              ],
              data: [
                MapDataModel(
                  [2, 3, 1, 2],
                  dataMarkerStyle: const DataMarkerStyle(
                    size: 3,
                    color: Colors.blue,
                  ),
                  connectLineStyle:
                      ConnectLineStyle(width: 6, color: Colors.red),
                ),
              ],
              radius: 100,
              shape: Shape.square,
              maxWidth: 80,
              line: LineModel(4),
            ),
            textStyle: const TextStyle(color: Colors.black, fontSize: 14),
            // lineText: (p, length) => "${(p * 100 ~/ length)}%",
            // dilogText: (IndicatorModel indicatorModel,
            //     List<LegendModel> legendModels, List<double> mapDataModels) {
            //   StringBuffer text = StringBuffer("");
            //   for (int i = 0; i < mapDataModels.length; i++) {
            //     text.write(
            //         "${legendModels[i].name} : ${mapDataModels[i].toString()}");
            //     if (i != mapDataModels.length - 1) {
            //       text.write("\n");
            //     }
            //   }
            //   return text.toString();
            // },
            // outLineText: (data, max) => "${data * 100 ~/ max}%",
          ),
        ),
      ),
    );
  }
}
