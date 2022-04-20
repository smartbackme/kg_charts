import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'radar_map_model.dart';
import 'radar_utils.dart';

class RadarWidget extends StatefulWidget {
  //数据传入
  final RadarMapModel radarMap;
  //文字风格
  TextStyle? textStyle;
  //是否绘制图例
  final bool? isNeedDrawLegend;

  final LineText? lineText;
  final DialogText? dilogText;
  final OutLineText? outLineText;

  RadarWidget({Key? key, required this.radarMap, this.textStyle, this.isNeedDrawLegend = true,this.lineText,this.dilogText,this.outLineText}):super(key:key){
    assert(radarMap.legend.length == radarMap.data.length);
    textStyle ??= TextStyle(color: Colors.black,fontSize: radarMap.radius * 0.10);
  }


  @override
  _RadarMapWidgetState createState() => _RadarMapWidgetState();
}

class _RadarMapWidgetState extends State<RadarWidget> with SingleTickerProviderStateMixin {
  double _angle = 0.0;
  late AnimationController controller; // 动画控制器
  late Animation<double> animation; // 动画实例
  double top = 0;
  double bottom = 0;
  List<Rect> node = [];
  TapModel tab = TapModel();
  final _counter = ValueNotifier(0);
  @override
  void initState() {
    super.initState();

    // 创建 Animation对象
    controller = AnimationController(duration: Duration(milliseconds: widget.radarMap.duration), vsync: this);
    // 创建曲线插值器
    var curveTween = CurveTween(curve: Cubic(0.96, 0.13, 0.1, 1.2));
    // 定义估值器
    var tween = Tween(begin: 0.0, end: 360.0);
    // 插值器根据时间产生值，并提供给估值器，作为animation的value
    animation = tween.animate(curveTween.animate(controller));
    animation.addListener(() {
      setState(() {
        _angle = animation.value;
      });
    });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    animation.removeListener(() {});
    super.dispose();
  }

  ///构建图例
  Widget buildLegend(String legendTitle, Color legendColor,{Color? textColor,double? textFontSize}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(color: legendColor, borderRadius: BorderRadius.all(Radius.circular(6))),
        ),
        Text(
          legendTitle,
          style: TextStyle(fontSize: textFontSize??10,color: textColor??Colors.black),
        )
      ],
    );
  }
  late int elementLength;//维度 数量

  // RadarUtils.getHeight(widget.radarMap.radius, widget.radarMap.indicator.length
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var painter = RadarMapPainter(w,top,widget.radarMap,(t,b){
      setState(() {
        top = t;
        bottom = b;
      });
    },node,tab,textStyle: widget.textStyle,lineText: widget.lineText,outLineText: widget.outLineText,dilogText : widget.dilogText,repaint: _counter);

    CustomPaint paint = CustomPaint(
      size: Size(w, RadarUtils.getHeight(widget.radarMap.radius, widget.radarMap.indicator.length,widget.radarMap.shape)+bottom+top),
      painter: painter,
    );



    // var center = Transform.rotate(
    //   // 旋转动画
    //   angle: -_angle / 180 * pi,
    //   child: Transform.scale(
    //     // 缩放动画
    //     scale: 0.5 + animation.value / 360 / 2,
    //     child: GestureDetector(child: paint,
    //       onTapUp: (TapUpDetails details){
    //         painter.tapUp(details);
    //       },
    //       onTapDown: (TapDownDetails details){
    //         painter.tapDown(details);
    //       },
    //       // onTap: (){
    //       //  print("onTap");
    //       // },
    //     ),
    //   ),
    // );

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(children: [

      GestureDetector(
          child: paint,
          onTapUp: (TapUpDetails details){
            painter.tapUp(details);
          },
          onTapDown: (TapDownDetails details){
            painter.tapDown(details);
            _counter.value++;
          }),
        Offstage(
          offstage: !widget.isNeedDrawLegend!,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top:20,bottom: 20,left: 30,right: 30),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                alignment: WrapAlignment.spaceAround,
                children: widget.radarMap.legend.map((item) => buildLegend(item.name, item.color,textColor: item.textColor,textFontSize: item.textFontSize)).toList(),
              ),
          ),
        ),
      ],
      ),
    );
  }
  // MainAxisAlignment.spaceAround



}

typedef LineText = String Function(int p,int length);
typedef OutLineText = String Function(double data,double maxValue);
typedef DialogText = String Function(IndicatorModel indicatorModel,List<LegendModel> legendModels,List<double> mapDataModels);
typedef WidthHeight = Function(double w,double h);

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
  late int elementLength;//维度 数量
  LineText? lineText;
  DialogText? dilogText;
  OutLineText? outLineText;
  WidthHeight _widthHeight;
  double w;
  double top;
  List<Rect> node;
  TapModel tab;
  RadarMapPainter(this.w,this.top,this.radarMap,this._widthHeight, this.node,this.tab,{this.textStyle,this.lineText,this.dilogText,this.outLineText,Listenable? repaint}) :super(repaint: repaint){
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

  void tapUp(TapUpDetails details){
  }

  void tapDown(TapDownDetails details){
    // // print("${details.globalPosition.dx-w/2} . ${details.globalPosition.dy-radarMap.radius-top}");
    // print("${details.localPosition.dx-w/2} . ${details.localPosition.dy-radarMap.radius-top}");
    // print("${node[0].left},${node[0].right},${node[0].top},${node[0].bottom}");
    // // print("${details.globalPosition.dx} . ${details.globalPosition.dy}");
    // // print("${details.localPosition.dx} . ${details.localPosition.dy}");
    // // print("${node.length}");
    for (int i=0;i< node.length;i++) {
      // print("${node[i].left} . ${node[i].top}");
      var n = node[i];
      var x = details.localPosition.dx-w/2;
      var y = details.localPosition.dy-radarMap.radius-top;

      if(x>=n.left && x<=n.right && y>=n.top&&y<=n.bottom){
        tab..x=x..y=y..index=i;
        return;
      }
    }
    tab.reset();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(w/2, radarMap.radius+top); // 移动坐标系
    drawInnerCircle(canvas, size);
    for (int i = 0; i < radarMap.legend.length; i++) {
      drawRadarMap(
          canvas,
          radarMap.data[i].data,
          radarMap.indicator.map((item) => item.maxValues).toList(),
          mAreaPaint..color = radarMap.legend[i].color.withAlpha(radarMap.alpha));
      drawRadarPath(
          canvas,
          radarMap.data[i].data,
          radarMap.indicator.map((item) => item.maxValues).toList(),
          mLineInnerPaint..color = radarMap.legend[i].color);
      drawRadarText(
          canvas,
          radarMap.data[i].data,
          radarMap.indicator.map((item) => item.maxValues).toList(),
          radarMap.legend[i].color);
    }

    drawInfoText(canvas);
    drawInfoDialog(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  /// 绘制内圈圆 || 内多边形、分割线  || 绘制文字
  drawInnerCircle(Canvas canvas, Size size) {
    double innerRadius = radarMap.radius; // 内圆半径
    var line = radarMap.line;
    int ring = line?.line??1;
    Color ringColor = line?.color??Colors.grey;
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
        var startRa = innerRadius/ring * s;

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
    if(lineText!=null){
      // (s/ring).toStringAsFixed(2)
      var maxWidth = 100.0;
      for (int s = ring; s > 0; s--) {
        ///起始位置
        var startRa = innerRadius/ring * s - radarMap.radius * 0.05;
        Offset offset = Offset(-maxWidth/2, -startRa);
        // fontSize: textStyle!.fontSize ?? radarMap.radius * 0.16,


        final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
            textAlign: TextAlign.center,
            fontSize: line?.textFontSize ?? radarMap.radius * 0.1,
            fontWeight: FontWeight.normal));
        paragraphBuilder.pushStyle(ui.TextStyle(color: line?.textColor??Colors.black , textBaseline: ui.TextBaseline.alphabetic));
        paragraphBuilder.addText(lineText!.call(s,ring));
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
  drawRadarMap(Canvas canvas, List<double> value, List<double> maxList, Paint mapPaint) {
    Path radarMapPath = Path();
    double step = radarMap.radius / elementLength; //每小段的长度
    radarMapPath.moveTo(0, -value[0] / (maxList[0] / elementLength) * step); //起点
    for (int i = 1; i < elementLength; i++) {
      double mark = value[i] / (maxList[i] / elementLength);
      var deg = pi / 180 * (360 / elementLength * i - 90);
      radarMapPath.lineTo(mark * step * cos(deg), mark * step * sin(deg));
    }
    radarMapPath.close();
    canvas.drawPath(radarMapPath, mapPaint);
  }

  /// 绘制边框
  drawRadarPath(Canvas canvas, List<double> value, List<double> maxList, Paint linePaint) {
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

  void drawRadarText(ui.Canvas canvas, List<double> value, List<double> maxList, Color color) {
    if(outLineText!=null){
      // Path mradarPath = Path();
      double step = radarMap.radius / elementLength; //每小段的长度
      // mradarPath.moveTo(0, -value[0] / (maxList[0] / value.length) * step);
      var maxWidth = 40.0;

      for (int i = 0; i < value.length; i++) {
        double mark = value[i] / (maxList[i] / value.length);
        var deg = pi / 180 * (360 / value.length * i - 90);

        final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
            textAlign: TextAlign.center,
            fontSize: radarMap.outTextSize??10,
            fontWeight: FontWeight.normal));
        paragraphBuilder.pushStyle(ui.TextStyle(color: color , textBaseline: ui.TextBaseline.alphabetic));
        paragraphBuilder.addText(outLineText!.call(value[i],maxList[i]));
        var paragraph = paragraphBuilder.build();
        paragraph.layout(ui.ParagraphConstraints(width: maxWidth));
        var pianyix = cos(deg)*(paragraph.width/2);
        var pianyiy = sin(deg)*(paragraph.height/2);
        var of = Offset(mark * step * cos(deg) -paragraph.width/2 +pianyix , mark * step * sin(deg) - paragraph.height/2 +pianyiy);
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
    var startRa = innerRadius ;
    var maxWidth = radarMap.maxWidth??40.0;
    var top = 0.0;
    var bottom = 0.0;
    ///角度
    double angle = 0;
    node.clear();
    for (int i = 0; i < elementLength; i++) {
      // drawText(
      //   canvas,
      //   radarMap.indicator[i].name,
      //   Offset(0 + startRa * sin(angle), 0 - startRa * cos(angle)),
      // );
      final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: textStyle!.fontSize,
          fontWeight: FontWeight.normal));
      paragraphBuilder.pushStyle(ui.TextStyle(color: textStyle!.color , textBaseline: ui.TextBaseline.alphabetic));
      paragraphBuilder.addText(radarMap.indicator[i].name);
      var paragraph = paragraphBuilder.build();
      paragraph.layout(ui.ParagraphConstraints(width: maxWidth));

      // print("${0 + startRa * sin(angle)-paragraph.width/2}======${0 - startRa * cos(angle) - paragraph.height/2}");
      // print("${0 + startRa * sin(angle)-paragraph.width/2}======${0 - startRa * cos(angle) - paragraph.height/2}");

      var out = 10;

      var pianyix = sin(angle)*(paragraph.width/2 + out) ;
      var pianyiy = cos(angle)*(paragraph.height/2 + out);
      var of = Offset(0 + startRa * sin(angle)-paragraph.width/2 +pianyix, 0 - startRa * cos(angle) - paragraph.height/2 - pianyiy);
      var rect = Rect.fromCenter(center: Offset(0 + startRa * sin(angle) +pianyix, 0 - startRa * cos(angle) - pianyiy), width: paragraph.width, height:paragraph.height);

      canvas.drawParagraph(paragraph, of);
      angle += delta;

      if(i == 0){
        top = paragraph.height + out;
      }

      if(elementLength%2==0){
        if(i == elementLength/2){
          bottom = paragraph.height + out;
        }
      }else{
        if(i == elementLength~/2){
          bottom = paragraph.height + out;
        }
        if(i == elementLength~/2+1){
          if(bottom<paragraph.height){
            bottom = paragraph.height + out;
          }
        }
      }

      node.add(rect);
    }


    // print("${node.length}");
    // node.forEach((element) {
    //   print("${element.left} . ${element.top} 11");
    // });

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _widthHeight.call(top,bottom);
    });

    //
    // for (int s = ring; s > 0; s--) {
    //   ///起始位置
    //   var startRa = innerRadius/ring * s - radarMap.radius * 0.05;
    //   Offset offset = Offset(-maxWidth/2, -startRa);
    //   // fontSize: textStyle!.fontSize ?? radarMap.radius * 0.16,
    //
    //
    //   final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
    //       textAlign: TextAlign.center,
    //       fontSize: line?.textFontSize ?? radarMap.radius * 0.1,
    //       fontWeight: FontWeight.normal));
    //   paragraphBuilder.pushStyle(ui.TextStyle(color: line?.textColor??Colors.black , textBaseline: ui.TextBaseline.alphabetic));
    //   paragraphBuilder.addText(lineText!.call(s,ring));
    //   var paragraph = paragraphBuilder.build();
    //   paragraph.layout(ui.ParagraphConstraints(width: maxWidth));
    //   canvas.drawParagraph(paragraph, offset);
    //
  }


  /// 绘制文字
  drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    // Color color = Colors.black,
    double maxWith = 100,
    // double fontSize,
    String? fontFamily,
    TextAlign textAlign = TextAlign.center,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    var paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontFamily: fontFamily,
        textAlign: textAlign,
        fontSize: textStyle!.fontSize ?? radarMap.radius * 0.16,
        fontWeight: fontWeight,
      ),
    );
    paragraphBuilder.pushStyle(ui.TextStyle(color: textStyle!.color ?? Colors.black, textBaseline: ui.TextBaseline.alphabetic));
    paragraphBuilder.addText(text);
    var paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: maxWith));
    canvas.drawParagraph(paragraph, Offset(offset.dx, offset.dy));
  }

  //绘制文本弹框
  void drawInfoDialog(ui.Canvas canvas) {
    if(tab.index!=null&&tab.x!=null&&tab.y!=null&&radarMap.dilog!&&dilogText!=null){
      List<LegendModel> legendModels = radarMap.legend.map((item) => item).toList();
      List<double> mapDataModels = radarMap.data.map((item) => item.data[tab.index!]).toList();
      // for(int i=0;i<radarMap.data.length;i++){
      //   legendModels.add(radarMap.legend[i]);
      //   mapDataModels.add(radarMap.data[i].data[tab.index!]);
      // }
      //

    IndicatorModel indicatorModel = radarMap.indicator[tab.index!];
      double maxWidth = radarMap.dialogModel?.maxWidth??150.0;

      final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: radarMap.dialogModel?.textFontSize??13,
          fontWeight: FontWeight.normal));
      paragraphBuilder.pushStyle(ui.TextStyle(color: Colors.white , textBaseline: ui.TextBaseline.alphabetic));



      paragraphBuilder.addText(dilogText!.call(indicatorModel,legendModels,mapDataModels));
      var paragraph = paragraphBuilder.build();
      paragraph.layout(ui.ParagraphConstraints(width: maxWidth));
      var rectx = tab.x! - paragraph.width/2;
      var recty = tab.y! + ((tab.y!>0)?-paragraph.height-sin(45)*10:sin(45)*10);

      var rect = RRect.fromLTRBR(rectx, recty, paragraph.width +rectx, paragraph.height+recty,const Radius.circular(15));
      canvas.drawRRect(rect, mDialogPaint);

      mDialogPath.moveTo(tab.x!, tab.y!);
      mDialogPath.lineTo(tab.x! -10,tab.y!+ ((tab.y!>0)?-10:10));
      mDialogPath.lineTo(tab.x! +10,tab.y!+((tab.y!>0)?-10:10));
      canvas.drawPath(mDialogPath,mDialogPaint);
      var of = Offset(rectx,recty);
      canvas.drawParagraph(paragraph, of);
      // var rect = Rect.fromCenter(center: Offset(tab.x! + ((tab.x!>0)?0:0), tab.y!), width: paragraph.width, height:paragraph.height);

    }
  }



}
