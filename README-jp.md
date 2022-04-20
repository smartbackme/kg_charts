## kg_charts
## kg_charts アイコンライブラリは、現在レーダーグラフのみで、後期に他のタイプのグラフが追加される可能性があります

### 開始

```dart
dependencies:
  kg_charts: ^0.0.1
```

レーダーグラフの効果は以下の通りです

![](art/img1.jpg)

![](art/img2.jpg)

![](art/img3.jpg)

![](art/img4.jpg)

![](art/img5.jpg)

画像の説明



![](art/img1.jpg)

使用方法例:

```dart

RadarWidget(
            radarMap: RadarMapModel(
                legend: [
                  LegendModel('10/10',const Color(0XFF0EBD8D)),
                  LegendModel('10/11',const Color(0XFFEAA035)),
                ],
                indicator: [
                  IndicatorModel("English",100),
                  IndicatorModel("Physics",100),
                  IndicatorModel("Chemistry",100),
                  IndicatorModel("Biology",100),
                  IndicatorModel("Politics",100),
                  IndicatorModel("History",100),
                ],
                data: [
                  //   MapDataModel([48,32.04,1.00,94.5,19,60,50,30,19,60,50]),
                  //   MapDataModel([42.59,34.04,1.10,68,99,30,19,60,50,19,30]),
                  MapDataModel([100,90,90,90,10,20]),
                  MapDataModel([90,90,90,90,10,20]),
                ],
                radius: 130,
                duration: 2000,
                shape: Shape.square,
                maxWidth: 70,
                line: LineModel(4),
            ),
            textStyle: const TextStyle(color: Colors.black,fontSize: 14),
            isNeedDrawLegend: true,
            lineText: (p,length) =>  "${(p*100~/length)}%",
            dilogText: (IndicatorModel indicatorModel,List<LegendModel> legendModels,List<double> mapDataModels) {
              StringBuffer text = StringBuffer("");
              for(int i=0;i<mapDataModels.length;i++){
                text.write("${legendModels[i].name} : ${mapDataModels[i].toString()}");
                if(i!=mapDataModels.length-1){
                  text.write("\n");
                }
              }
              return text.toString();
            },
            outLineText: (data,max)=> "${data*100~/max}%",
          ),

```

パラメータの説明:

| パラメータ | タイプ | 必要かどうか | 説明
|--|--|--|--|
| radarMap| RadarMapModel| yes | 図例、レーダーポイント、レーダーデータ、半径、レーダー種類(円形、四角形)、文字の最大幅、内部にいくつかの線(LineModelには描画線の色、文字の大きさなどが含まれています  |
| textStyle | style | no | 外部描画文字の色とサイズ |
|isNeedDrawLegend  | bool  |  no | デフォルトはtrue |
| lineText | fun | no  | 内部線画の文字は、データに基づいて動的に生成され、空の場合は表示されません |
|dilogText  |  fun | no  | 出現したdialogをクリックし、データに基づいて動的に生成し、空であれば表示しない |
| outLineText | fun  | no  | 外部線上に描かれた文字は、データに基づいて動的に生成され、空であれば表示されない |
