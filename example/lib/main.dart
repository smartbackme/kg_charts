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
          // height: 300,
          // width: 300,
          alignment: AlignmentDirectional.center,
          child: RadarWidget(
            skewing: 0,
            radarMap: RadarMapModel(
              legend: [
                LegendModel('Low', Colors.red),
                LegendModel('Medium', Colors.yellow),
                LegendModel('High', Colors.green),
              ],
              indicator: [
                IndicatorModel("English", 3),
                IndicatorModel("Physics", 3),
                IndicatorModel("Chemistry", 3),
                IndicatorModel("Biology", 3),
              ],
              data: [
                //   MapDataModel([48,32.04,1.00,94.5,19,60,50,30,19,60,50]),
                //   MapDataModel([42.59,34.04,1.10,68,99,30,19,60,50,19,30]),
                MapDataModel([1, 1, 1, 1]),
                MapDataModel([2, 2, 2, 2]),
                MapDataModel([3, 3, 3, 3]),
              ],
              radius: 100,
              duration: 1000,
              shape: Shape.square,
              maxWidth: 80,
              line: LineModel(3),
            ),
            textStyle: const TextStyle(color: Colors.black, fontSize: 14),
            isNeedDrawLegend: true,
            // lineText: (p, length) => "${(p * 100 ~/ length)}%",
            lineText: (p, length) => "",
            dilogText: (IndicatorModel indicatorModel,
                List<LegendModel> legendModels, List<double> mapDataModels) {
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
            // outLineText: (data, max) => "${data * 100 ~/ max}%",
            outLineText: (data, max) => "",
          ),
        ),
      ),
    );
  }
}
