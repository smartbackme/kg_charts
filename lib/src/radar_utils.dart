

import 'dart:math';

import 'radar_map_model.dart';

class RadarUtils{

  static double getHeight(double radius,int length,Shape shape){
    if(shape==Shape.circle){
      return radius * 2;
    }
    if(length==2){
      return radius * 2;
    }
    if(length==0||length==1){
      return 0;
    }
    switch(length){
      case 3:
        return radius + radius*0.5;
      case 5:
        return radius - (radius*sin(30));
    }
    return radius * 2;
  }

}