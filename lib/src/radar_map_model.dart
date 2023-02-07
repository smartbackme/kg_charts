// Modeified by SehunKIM 2023.02.07

import 'package:flutter/material.dart';

// 圆形雷达图和方形雷达图
enum Shape { circle, square }

class RadarMapModel {
  List<LegendModel> legend;
  List<MapDataModel> data;
  List<IndicatorModel> indicator;
  Shape shape;
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

  //splitArea,splited background areas
  SplitAreaStyle splitAreaStyle;

  //splitArea,splited background areas
  VisualMap? visualMap;

  RadarMapModel({
    this.legend = const [],
    required this.data,
    required this.indicator,
    required this.radius,
    this.shape = Shape.circle,
    this.line,
    this.alpha = 80,
    this.dilog = true,
    this.dialogModel,
    this.outTextSize,
    this.maxWidth,
    this.splitAreaStyle = const SplitAreaStyle(),
    this.visualMap,
  });
}

class TapModel {
  double? x;
  double? y;
  int? index;

  TapModel({this.x, this.y, this.index});

  void reset() {
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

  LineModel(this.line, {this.color, this.textFontSize, this.textColor});
}

//Dilaog
class DialogModel {
  final double? maxWidth;
  final double? textFontSize;
  final Color? textColor;

  DialogModel({this.maxWidth, this.textFontSize, this.textColor});
}

/// 考虑legend、Dimension、data的长度对应关系

// 指标 model
class LegendModel {
  final String name;
  final Color color;
  final Color? textColor;
  final double? textFontSize;

  LegendModel(this.name, this.color, {this.textColor, this.textFontSize});
}

//  维度 model
class IndicatorModel {
  final String name; // 维度名称
  final double maxValues; // 当前维度的最大值
  final Color? textColor;
  final double? textFontSize;

  IndicatorModel(this.name, this.maxValues,
      {this.textColor, this.textFontSize});
}

// 根据每个legend给出维度的值列表
class MapDataModel {
  final List<double> data;
  final ConnectLineStyle? connectLineStyle;
  final DataAreaStyle dataAreaStyle;
  DataMarkerStyle dataMarkerStyle;
  MapDataModel(this.data,
      {this.connectLineStyle,
      this.dataAreaStyle = const DataAreaStyle(),
      this.dataMarkerStyle = const DataMarkerStyle()});
}

// AreaStyle for splitArea
class SplitAreaStyle {
  final List<Color> colors;
  final int alpha;

  const SplitAreaStyle({this.colors = const [], this.alpha = 50});
}

class DataAreaStyle {
  final Color color;
  final int alpha;
  const DataAreaStyle({this.color = Colors.white, this.alpha = 0});
}

class DataMarkerStyle {
  final double size;
  final Color? color;
  final int alpha;

  const DataMarkerStyle({this.size = 3, this.color, this.alpha = 1});
}

class VisualMap {
  String type;
  double width;
  double height;
  List<Color> colors;
  List<String> texts;
  TextStyle textStyle;
  VisualMap({
    this.type = 'continuous',
    this.width = 260,
    this.height = 30,
    this.colors = const [],
    this.texts = const [],
    this.textStyle = const TextStyle(),
  });
}

class ConnectLineStyle {
  Color color;
  double width;
  ConnectLineStyle({
    required this.color,
    required this.width,
  });
}
