import 'package:flutter/material.dart';
// 圆形雷达图和方形雷达图
enum Shape { circle, square }

class RadarMapModel {
  List<LegendModel> legend;
  List<MapDataModel> data;
  List<IndicatorModel> indicator;
  Shape shape;
  //动画时间
  int duration;
  //半径
  double radius;
  // (which ranges from 0 to 255).
  int alpha;

  bool? dilog;

  LineModel? line;

  DialogModel? dialogModel;

  double? outTextSize;
  //文字大小
  double? maxWidth;

  RadarMapModel({required this.legend, required this.data, required this.indicator, required this.radius, this.duration = 2000, this.shape = Shape.circle,this.line,this.alpha = 80,this.dilog = true,this.dialogModel,this.outTextSize});
}



class TapModel{
  double? x;
  double? y;
  int? index;


  TapModel({this.x, this.y, this.index});

  void reset(){
    x = null;
    y = null;
    index = null;
  }
}

//绘制分割线
class LineModel {
  final int line;
  final Color? color;
  final double? textFontSize;
  final Color? textColor;


  LineModel(this.line, {this.color,this.textFontSize,this.textColor});
}

//Dilaog
class DialogModel {
  final double? maxWidth;
  final double? textFontSize;
  final Color? textColor;


  DialogModel({this.maxWidth,this.textFontSize,this.textColor});
}

/// 考虑legend、Dimension、data的长度对应关系

// 指标 model
class LegendModel {
  final String name;
  final Color color;
  final Color? textColor;
  final double? textFontSize;

  LegendModel(this.name, this.color,{this.textColor,this.textFontSize});
}

//  维度 model
class IndicatorModel {
  final String name; // 维度名称
  final double maxValues; // 当前维度的最大值
  final Color? textColor;
  final double? textFontSize;

  IndicatorModel(this.name, this.maxValues,{this.textColor,this.textFontSize});
}

// 根据每个legend给出维度的值列表
class MapDataModel {
  final List<double> data;

//  final String legendName;

  MapDataModel(this.data);
}
