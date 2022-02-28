import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exerlog/Bloc/exercise_bloc.dart';
import 'package:exerlog/Bloc/max_bloc.dart';
import 'package:exerlog/Models/exercise.dart';
import 'package:exerlog/Models/maxes.dart';
import 'package:exerlog/Models/sets.dart';
import 'package:exerlog/Models/workout.dart';
import 'package:exerlog/UI/global.dart';
import 'package:exerlog/UI/maxes/max_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetWidget extends StatefulWidget {
  final String name;
  final Exercise exercise;
  Function(Exercise, Sets, int) addNewSet;
  //Function(Sets, int) createNewSet;
  final bool isTemplate;
  int id;

  SetWidget(
      {required this.name,
      required this.exercise,
      required this.addNewSet,
      //required this.createNewSet,
      required this.id,
      required this.isTemplate});
  @override
  _SetWidgetState createState() => _SetWidgetState();
}

class _SetWidgetState extends State<SetWidget>
  with AutomaticKeepAliveClientMixin {
  int percent = 0;
  Max? oneRepMax;
  Sets sets = new Sets(0, 0, 0, 0);
  String percentageController = '0%';
  TextEditingController setsController = new TextEditingController();
  TextEditingController repsController = new TextEditingController();
  TextEditingController weightController = new TextEditingController();
  TextEditingController restController = new TextEditingController();
  List types = ['reps', 'sets', 'weight', 'rest', ''];
  MaxInformation? maxinfoWidget;
  ValueNotifier<double> _notifier = ValueNotifier(0.0);

  @override
  void initState() {
    //percentageProvider = Provider.of<PercentageProvider>(context, listen: false);
    // TODO: implement initState
    _notifier.value = widget.exercise.sets[widget.id].weight;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getSetWidget();
  }

  Container getSetWidget() {
    return Container(
      height: screenHeight * 0.05,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Center(
                child: Text(
              "#" + (widget.id + 1).toString(),
              style: setStyle,
            )),
            width: screenWidth * 0.08,
          ),
          Container(
            child: getTextField(0),
            width: screenWidth * 0.145,
          ),
          Container(
            child: getTextField(1),
            width: screenWidth * 0.145,
          ),
          Container(
            child: getTextField(2),
            width: screenWidth * 0.145,
          ),
          Container(
            child: getTextField(3),
            width: screenWidth * 0.145,
          ),
          Container(
            child: ValueListenableBuilder(
            valueListenable: _notifier,
            builder: (BuildContext context, double value, Widget? child) {
              return MaxInformation(id: widget.exercise.name, weight: value, setMax: setOneRepMax);
            } 
          ), 
            width: screenWidth * 0.11,
          ),
        ],
      ),
    );
  }

  void setOneRepMax(Max max) {
    oneRepMax = max;
  }

  Widget getTextField(int type) {
    List controllers = [
      repsController,
      setsController,
      weightController,
      restController
    ];


      controllers[type].text = getHintText(type);
      return TextField(
      cursorColor: Colors.white,
      style: setStyle,
      textAlign: TextAlign.center,
      keyboardType: type == 2 ? TextInputType.text : TextInputType.number,
      controller: controllers[type],
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        hintText: getHintText(type),
        hintStyle: setHintStyle,
      ),
      onChanged: (value) {
        sets.reps = getInfo(repsController.text, 0);
        sets.sets = getInfo(setsController.text, 0);
        if (weightController.text.contains('%')) {
          // set weight to be percentage of max
          var regex = new RegExp(r'\D');
          sets.weight = getWeightFromMax(weightController.text.replaceAll(regex, ''));
          weightController.text = sets.weight.toString();
          _notifier.value = sets.weight;
        }
        sets.weight = getInfo(weightController.text, 1);
        sets.rest = getInfo(restController.text, 1);
        if (sets.sets == 0.0) {
          sets.sets = 1;
        }
        widget.addNewSet(widget.exercise, sets, widget.id);
        try {
          _notifier.value = sets.weight;
        } catch (Exception) {
          print("Percentage exception:");
          print(Exception);
        }
        //percent = (sets.weight / oneRepMax).round();
      },
    );
  }

  dynamic getInfo(String text, int type) {
    try {
      if (type == 0) {
        return int.parse(text);
      } else {
        return double.parse(text);
      }
    } catch (Exception) {
      if (type == 0) {
        return 0;
      } else {
        return 0.0;
      }
    }
  }

  double getWeightFromMax(String percentage) {
    var result = oneRepMax!.weight / maxTable[oneRepMax!.reps -1];
    print("RESULT " + result.toString());
    print(oneRepMax!.weight);
    print(oneRepMax!.reps);
    double the_percent = double.parse(percentage) / 100;
    print(the_percent);
    return (result * the_percent).roundToDouble();
  }

  String getHintText(int type) {
    List listType = [
      widget.exercise.sets[widget.id].reps,
      widget.exercise.sets[widget.id].sets,
      widget.exercise.sets[widget.id].weight,
      widget.exercise.sets[widget.id].rest,
    ];
    String returnText = '';
    print("TEXT: " + listType[type].toString());
    try {
      returnText = listType[type].toString();
    } catch (Exception) {}
    return returnText;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
