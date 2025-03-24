// ignore_for_file: unused_field, unused_import
import 'dart:collection';
import 'package:flutter/material.dart';

//A class that represents the logging of the steps
class Log{
  late final int _logId; //unique identifier of the group
  late DateTime _logDate; // mm/dd/yyyy of the log
  int _stepCount = 0; //number of steps of user

  Log(int logId, DateTime logDate, int stepCount){
    _logId = logId;
    _logDate = logDate;
    if(stepCount >= 0){_stepCount = stepCount;}
    else{_stepCount = 0;}
  }

  set setlogId(int logId){
    _logId = logId;
  }
  
  int get getlogId{
    return _logId;
  }

  set setLogDate(DateTime logDate){
    _logDate = logDate;
  }
  
  DateTime get getLogDate{
    return _logDate;
  }

  set setStepCount(int stepCount){
    if(stepCount >= 0){_stepCount = stepCount;}
    else{_stepCount = 0;}
  }
  
  int get getStepCount{
    return _stepCount;
  }
}