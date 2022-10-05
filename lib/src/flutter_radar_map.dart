import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'radar_map_model.dart';
import 'radar_utils.dart';

@immutable
class RadarWidget extends StatefulWidget {
  //数据传入
  final RadarMapModel radarMap;
  //文字风格
  final TextStyle? textStyle;
  //是否绘制图例
  final bool? isNeedDrawLegend;
  //是否绘制视觉映射
  final bool? isNeedDrawVisualMap;

  final LineText? lineText;
  final DialogText? dilogText;
  final OutLineText? outLineText;

  final double? skewing;

  RadarWidget(
      {Key? key,
      required this.radarMap,
      this.textStyle = const TextStyle(color: Colors.black),
      this.isNeedDrawLegend = false,
      this.isNeedDrawVisualMap = false,
      this.lineText,
      this.dilogText,
      this.outLineText,
      this.skewing})
      : super(key: key) {
    // assert(radarMap.legend.length == radarMap.data.length);
  }

  @override
  _RadarMapWidgetState createState() => _RadarMapWidgetState();
}

class _RadarMapWidgetState extends State<RadarWidget>
    with SingleTickerProviderStateMixin {
  // double _angle = 0.0;
  // late AnimationController controller; // 动画控制器
  // late Animation<double> animation; // 动画实例
  double top = 27;
  double bottom = 27;
  List<Rect> node = [];
  TapModel tab = TapModel();
  final _counter = ValueNotifier(0);
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///构建图例
  Widget buildLegend(String legendTitle, Color legendColor,
      {Color? textColor, double? textFontSize}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
              color: legendColor,
              borderRadius: const BorderRadius.all(Radius.circular(6))),
        ),
        Text(
          legendTitle,
          style: TextStyle(
              fontSize: textFontSize ?? 10, color: textColor ?? Colors.black),
        )
      ],
    );
  }

  ///构建图例
  Widget buildVisualMap(VisualMap visualMap) {
    return SizedBox(
      height: visualMap.height,
      width: visualMap.width,
      child: Row(
        children: [
          SizedBox(
              width: 50,
              child: Text(visualMap.texts.first, textAlign: TextAlign.right)),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var maxWidth = constraints.maxWidth;
                var maxHeight = constraints.maxHeight;
                return Container(
                    width: maxWidth,
                    height: maxHeight,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: visualMap.colors,
                    )));
              },
            ),
          ),
          SizedBox(
              width: 50,
              child: Text(visualMap.texts.last, textAlign: TextAlign.left)),
        ],
      ),
    );
  }

  late int elementLength; //维度 数量

  // RadarUtils.getHeight(widget.radarMap.radius, widget.radarMap.indicator.length
  @override
  Widget build(BuildContext context) {
    double sk = (widget.skewing ?? 0.0) > 40 ? 40 : (widget.skewing ?? 0.0);
    if (sk < 0) {
      sk = 0;
    }
    var w = MediaQuery.of(context).size.width;
    var painter = RadarMapPainter(w, top, widget.radarMap, (t, b) {
      // setState(() {
      // top = t;
      // bottom = b;
      // });
    }, node, tab, sk,
        textStyle: widget.textStyle,
        lineText: widget.lineText,
        outLineText: widget.outLineText,
        dilogText: widget.dilogText,
        repaint: _counter);

    CustomPaint paint = CustomPaint(
      size: Size(
          w,
          RadarUtils.getHeight(widget.radarMap.radius,
                  widget.radarMap.indicator.length, widget.radarMap.shape) +
              bottom +
              top),
      painter: painter,
    );

    return Column(children: [
      paint,
      widget.isNeedDrawLegend == true
          ? Offstage(
              offstage: widget.isNeedDrawLegend!,
              child: Padding(
                padding: EdgeInsets.only(right: sk),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                      top: 20, bottom: 20, left: 30, right: 30),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.spaceAround,
                    children: widget.radarMap.legend
                        .where((item) => item.name != "")
                        .toList()
                        .map((item) => buildLegend(item.name, item.color,
                            textColor: item.textColor,
                            textFontSize: item.textFontSize))
                        .toList(),
                  ),
                ),
              ))
          : const SizedBox.shrink(),
      Offstage(
        offstage: !widget.isNeedDrawVisualMap!,
        child: widget.radarMap.visualMap == null
            ? const SizedBox.shrink()
            : Container(
                margin: const EdgeInsets.all(12),
                child:
                    buildVisualMap(widget.radarMap.visualMap ?? VisualMap())),
      )
    ]);
  }
  // MainAxisAlignment.spaceAround

}

typedef LineText = String Function(int p, int length);
typedef OutLineText = String Function(double data, double maxValue);
typedef DialogText = String Function(IndicatorModel indicatorModel,
    List<LegendModel> legendModels, List<double> mapDataModels);
typedef WidthHeight = Function(double w, double h);

/// canvas绘制
class RadarMapPainter extends CustomPainter {
  RadarMapModel radarMap;
  late Paint mLinePaint; // 线画笔
  late Paint mLineInnerPaint; // 线画笔
  late Paint mAreaPaint; // 区域画笔
  Paint? mFillPaint; // 填充画笔
  TextStyle? textStyle;
  late Path mLinePath; // 短直线路径
  late Path mDialogPath; // 短直线路径
  late Paint mDialogPaint; // 短直线路径
  late int elementLength; //维度 数量
  LineText? lineText;
  DialogText? dilogText;
  OutLineText? outLineText;
  final WidthHeight _widthHeight;
  double w;
  double top;
  List<Rect> node;
  TapModel tab;
  double skewing;
  RadarMapPainter(this.w, this.top, this.radarMap, this._widthHeight, this.node,
      this.tab, this.skewing,
      {this.textStyle,
      this.lineText,
      this.dilogText,
      this.outLineText,
      Listenable? repaint})
      : super(repaint: repaint) {
    mLinePath = Path();
    mDialogPath = Path();
    mLinePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.008 * radarMap.radius
      ..isAntiAlias = true;
    mDialogPaint = Paint() //填充画笔
      ..color = const Color(0xE64C4C4C)
      ..isAntiAlias = true;
    mFillPaint = Paint() //填充画笔
      ..strokeWidth = 0.05 * radarMap.radius
      ..color = Colors.black
      ..isAntiAlias = true;
    mLineInnerPaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    mAreaPaint = Paint()..isAntiAlias = true;
    elementLength = radarMap.indicator.length;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(w / 2 - skewing, radarMap.radius + top); // 移动坐标系
    drawInnerCircle(canvas, size);
    var maxValue =
        radarMap.indicator.map((item) => item.maxValues).toList().reduce(max);

    ///draw splitArea
    Path previousRadarMapPath;
    for (int i = 0; i < radarMap.splitAreaStyle.colors.length; i++) {
      previousRadarMapPath = getBackgroundPath(
        canvas,
        i * maxValue / radarMap.splitAreaStyle.colors.length,
        maxValue,
      );
      Path radarMapPath = getBackgroundPath(
        canvas,
        (i + 1) * maxValue / radarMap.splitAreaStyle.colors.length,
        maxValue,
      );
      canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          radarMapPath,
          previousRadarMapPath,
        ),
        mAreaPaint
          ..color = radarMap.splitAreaStyle.colors[i]
              .withAlpha(radarMap.splitAreaStyle.alpha),
      );
    }

    ///draw
    for (int i = 0; i < radarMap.data.length; i++) {
      drawRadarMap(
          canvas,
          radarMap.data[i].data,
          radarMap.indicator.map((item) => item.maxValues).toList(),
          mAreaPaint
            ..color = radarMap.data[i].dataAreaStyle.color
                .withAlpha(radarMap.data[i].dataAreaStyle.alpha));

      drawRadarPath(
          canvas,
          radarMap.data[i].data,
          radarMap.indicator.map((item) => item.maxValues).toList(),
          mLineInnerPaint
            ..strokeWidth = radarMap.data[i].connectLineStyle?.width ?? 3
            ..color = radarMap.data[i].connectLineStyle?.color ??
                radarMap.data[i].dataAreaStyle.color);
      drawDataMarker(
          canvas,
          radarMap.data[i].data,
          radarMap.indicator.map((item) => item.maxValues).toList(),
          mAreaPaint
            ..strokeWidth = radarMap.data[i].dataMarkerStyle.size
            ..color = radarMap.data[i].dataMarkerStyle.color ??
                radarMap.data[i].connectLineStyle?.color ??
                radarMap.data[i].dataAreaStyle.color);
      drawRadarText(
          canvas,
          radarMap.data[i].data,
          radarMap.indicator.map((item) => item.maxValues).toList(),
          radarMap.data[i].dataAreaStyle.color);
    }

    drawInfoText(canvas);
    // drawInfoDialog(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  /// 绘制内圈圆 || 内多边形、分割线  || 绘制文字
  drawInnerCircle(Canvas canvas, Size size) {
    double innerRadius = radarMap.radius; // 内圆半径
    var line = radarMap.line;
    int ring = line?.line ?? 1;
    Color ringColor = line?.color ?? Colors.grey;
    if (radarMap.shape == Shape.circle) {
      /// 绘制五个圆环
      for (int s = ring; s > 0; s--) {
        canvas.drawCircle(
          const Offset(0, 0),
          innerRadius / ring * s,
          mLinePaint
            ..color = ringColor
            ..style = PaintingStyle.stroke,
        );
      }
    } else {
      /// 绘制五个方环

      ///均分圆的度数
      double delta = 2 * pi / elementLength;
      for (int s = ring; s > 0; s--) {
        ///起始位置
        var startRa = innerRadius / ring * s;

        Path mapPath = Path();

        ///角度
        double angle = 0;
        mapPath.moveTo(0, -startRa);
        for (int i = 0; i < elementLength; i++) {
          angle += delta;
          mapPath.lineTo(0 + startRa * sin(angle), 0 - startRa * cos(angle));
        }
        mapPath.close();
        canvas.drawPath(
          mapPath,
          mLinePaint
            ..color = ringColor
            ..style = PaintingStyle.stroke,
        );
      }
    }
    // 图上画文字
    if (lineText != null) {
      // (s/ring).toStringAsFixed(2)
      var maxWidth = 100.0;
      for (int s = ring; s > 0; s--) {
        ///起始位置
        var startRa = innerRadius / ring * s - radarMap.radius * 0.05;
        Offset offset = Offset(-maxWidth / 2, -startRa);
        // fontSize: textStyle!.fontSize ?? radarMap.radius * 0.16,

        final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
            textAlign: TextAlign.center,
            fontSize: line?.textFontSize ?? radarMap.radius * 0.1,
            fontWeight: FontWeight.normal));
        paragraphBuilder.pushStyle(ui.TextStyle(
            color: line?.textColor ?? Colors.black,
            textBaseline: ui.TextBaseline.alphabetic));
        paragraphBuilder.addText(lineText!.call(s, ring));
        var paragraph = paragraphBuilder.build();
        paragraph.layout(ui.ParagraphConstraints(width: maxWidth));
        canvas.drawParagraph(paragraph, offset);
      }
    }

    // 遍历画线
    for (var i = 0; i < elementLength; i++) {
      canvas.save();
      canvas.rotate(360 / elementLength * i.toDouble() / 180 * pi);
      mLinePath.moveTo(0, -innerRadius);
      mLinePath.relativeLineTo(0, innerRadius); //线的路径
      canvas.drawPath(
          mLinePath,
          mLinePaint
            ..color = ringColor
            ..style = PaintingStyle.stroke); //绘制线
      canvas.restore();
    }

    canvas.save();
    canvas.restore();
  }

  /// 绘制区域
  Path drawRadarMap(
      Canvas canvas, List<double> value, List<double> maxList, Paint mapPaint) {
    Path radarMapPath = Path();
    double step = radarMap.radius / elementLength; //每小段的长度
    radarMapPath.moveTo(
        0, -value[0] / (maxList[0] / elementLength) * step); //起点
    for (int i = 1; i < elementLength; i++) {
      double mark = value[i] / (maxList[i] / elementLength);
      var deg = pi / 180 * (360 / elementLength * i - 90);
      radarMapPath.lineTo(mark * step * cos(deg), mark * step * sin(deg));
    }
    radarMapPath.close();
    canvas.drawPath(radarMapPath, mapPaint);
    return radarMapPath;
  }

  /// 背景区域
  Path getBackgroundPath(Canvas canvas, double value, double max) {
    Path radarMapPath = Path();
    double step = radarMap.radius / elementLength; //每小段的长度
    radarMapPath.moveTo(0, -value / (max / elementLength) * step); //起点
    for (int i = 1; i < elementLength; i++) {
      double mark = value / (max / elementLength);
      var deg = pi / 180 * (360 / elementLength * i - 90);
      radarMapPath.lineTo(mark * step * cos(deg), mark * step * sin(deg));
    }
    radarMapPath.close();
    return radarMapPath;
  }

  /// draw split area
  Path drawRadarSplitArea(
      Canvas canvas, value, double maxValue, Paint mapPaint) {
    Path radarMapPath = Path();
    double step = radarMap.radius / elementLength; //每小段的长度
    radarMapPath.moveTo(0, -value / (maxValue / elementLength) * step); //起点
    for (int i = 1; i < elementLength; i++) {
      double mark = value / (maxValue / elementLength);
      var deg = pi / 180 * (360 / elementLength * i - 90);
      radarMapPath.lineTo(mark * step * cos(deg), mark * step * sin(deg));
    }
    radarMapPath.close();
    canvas.drawPath(radarMapPath, mapPaint);
    return radarMapPath;
  }

  /// 绘制背景
  Path drawRadarBackground(
      Canvas canvas, List<double> value, List<double> maxList, Paint mapPaint) {
    Path radarMapPath = Path();
    double step = radarMap.radius / elementLength; //每小段的长度
    radarMapPath.moveTo(
        0, -value[0] / (maxList[0] / elementLength) * step); //起点
    for (int i = 1; i < elementLength; i++) {
      double mark = value[i] / (maxList[i] / elementLength);
      var deg = pi / 180 * (360 / elementLength * i - 90);
      radarMapPath.lineTo(mark * step * cos(deg), mark * step * sin(deg));
    }
    radarMapPath.close();
    canvas.drawPath(radarMapPath, mapPaint);
    return radarMapPath;
  }

  /// 绘制边框
  drawRadarPath(
      Canvas canvas, List<double> value, List<double> maxList, Paint linePaint,
      {drawRadarPath}) {
    Path mradarPath = Path();
    double step = radarMap.radius / value.length; //每小段的长度
    mradarPath.moveTo(0, -value[0] / (maxList[0] / value.length) * step);
    for (int i = 1; i < value.length; i++) {
      double mark = value[i] / (maxList[i] / value.length);
      var deg = pi / 180 * (360 / value.length * i - 90);
      mradarPath.lineTo(mark * step * cos(deg), mark * step * sin(deg));
    }
    mradarPath.close();
    canvas.drawPath(mradarPath, linePaint);
  }

  /// 绘制Data Marker
  drawDataMarker(
      Canvas canvas, List<double> value, List<double> maxList, Paint linePaint,
      {drawRadarPath}) {
    double step = radarMap.radius / value.length; //每小段的长度
    // canvas.drawCircle(Offset(0, -step), 10, linePaint);
    for (int i = 0; i < value.length; i++) {
      double mark = value[i] / (maxList[i] / value.length);
      var deg = pi / 180 * (360 / value.length * i - 90);
      canvas.drawCircle(Offset(mark * step * cos(deg), mark * step * sin(deg)),
          10, linePaint);
    }
  }

  void drawRadarText(
      ui.Canvas canvas, List<double> value, List<double> maxList, Color color) {
    if (outLineText != null) {
      // Path mradarPath = Path();
      double step = radarMap.radius / elementLength; //每小段的长度
      // mradarPath.moveTo(0, -value[0] / (maxList[0] / value.length) * step);
      var maxWidth = 40.0;

      for (int i = 0; i < value.length; i++) {
        double mark = value[i] / (maxList[i] / value.length);
        var deg = pi / 180 * (360 / value.length * i - 90);

        final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
            textAlign: TextAlign.center,
            fontSize: radarMap.outTextSize ?? 10,
            fontWeight: FontWeight.normal));
        paragraphBuilder.pushStyle(ui.TextStyle(
            color: color, textBaseline: ui.TextBaseline.alphabetic));
        paragraphBuilder.addText(outLineText!.call(value[i], maxList[i]));
        var paragraph = paragraphBuilder.build();
        paragraph.layout(ui.ParagraphConstraints(width: maxWidth));
        var pianyix = cos(deg) * (paragraph.width / 2);
        var pianyiy = sin(deg) * (paragraph.height / 2);
        var of = Offset(mark * step * cos(deg) - paragraph.width / 2 + pianyix,
            mark * step * sin(deg) - paragraph.height / 2 + pianyiy);
        canvas.drawParagraph(paragraph, of);

        // mradarPath.lineTo(mark * step * cos(deg), mark * step * sin(deg));
      }
      // mradarPath.close();
      // canvas.drawPath(mradarPath, linePaint);
    }
  }

  /// 绘制顶点文字
  void drawInfoText(Canvas canvas) {
    // double r2 = radarMap.radius + 2; //下圆半径
    // for (int i = 0; i < elementLength; i++) {
    //   Offset offset;
    //   canvas.save();
    //   if (i != 0) {
    //     canvas.rotate(360 / elementLength * i / 180 * pi + pi);
    //     offset = Offset(-50, r2);
    //   } else {
    //     offset = Offset(-50, -r2 - textStyle!.fontSize! - 8);
    //   }
    //   drawText(
    //     canvas,
    //     radarMap.indicator[i].name,
    //     offset,
    //   );
    //   canvas.restore();
    // }

    double innerRadius = radarMap.radius; // 内圆半径
    double delta = 2 * pi / elementLength;
    var startRa = innerRadius;
    var maxWidth = radarMap.maxWidth ?? 40.0;
    var top = 0.0;
    var bottom = 0.0;

    ///角度
    double angle = 0;
    node.clear();
    for (int i = 0; i < elementLength; i++) {
      final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: textStyle!.fontSize ?? radarMap.radius * 0.10,
          fontWeight: FontWeight.normal));
      paragraphBuilder.pushStyle(ui.TextStyle(
          color: textStyle!.color, textBaseline: ui.TextBaseline.alphabetic));
      paragraphBuilder.addText(radarMap.indicator[i].name);
      var paragraph = paragraphBuilder.build();
      paragraph.layout(ui.ParagraphConstraints(width: maxWidth));

      // print("${0 + startRa * sin(angle)-paragraph.width/2}======${0 - startRa * cos(angle) - paragraph.height/2}");
      // print("${0 + startRa * sin(angle)-paragraph.width/2}======${0 - startRa * cos(angle) - paragraph.height/2}");

      var out = 10;

      var pianyix = sin(angle) * (paragraph.width / 2 + out);
      var pianyiy = cos(angle) * (paragraph.height / 2 + out);
      var of = Offset(0 + startRa * sin(angle) - paragraph.width / 2 + pianyix,
          0 - startRa * cos(angle) - paragraph.height / 2 - pianyiy);
      var rect = Rect.fromCenter(
          center: Offset(0 + startRa * sin(angle) + pianyix - skewing,
              0 - startRa * cos(angle) - pianyiy),
          width: paragraph.width,
          height: paragraph.height);

      canvas.drawParagraph(paragraph, of);
      angle += delta;

      if (i == 0) {
        top = paragraph.height + out;
      }

      if (elementLength % 2 == 0) {
        if (i == elementLength / 2) {
          bottom = paragraph.height + out;
        }
      } else {
        if (i == elementLength ~/ 2) {
          bottom = paragraph.height + out;
        }
        if (i == elementLength ~/ 2 + 1) {
          if (bottom < paragraph.height) {
            bottom = paragraph.height + out;
          }
        }
      }

      node.add(rect);
    }

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _widthHeight.call(top, bottom);
    });
  }
}
