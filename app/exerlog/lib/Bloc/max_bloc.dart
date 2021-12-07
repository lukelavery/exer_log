import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exerlog/Bloc/user_bloc.dart';
import 'package:exerlog/Models/exercise.dart';
import 'package:exerlog/Models/maxes.dart';
import 'package:exerlog/Models/sets.dart';
import 'package:exerlog/Models/workout.dart';
import 'package:firebase_core/firebase_core.dart';

import '../main.dart';


deleteMax() {}




Future<List<Max>> getSpecificMax(String exercise, double reps) async {
  final ref = await FirebaseFirestore.instance
  .collection('users')
  .doc(userID)
  .collection('maxes')
  .where('exercise', isEqualTo: exercise)
  .where('reps', isEqualTo: reps)
  .get();
  List<Max> maxList = [];
  for (int i = 0; i < ref.docs.length; i++) {
    final data = FirebaseFirestore.instance.collection('users').doc(userID).collection('maxes').doc(ref.docs[i].id).withConverter<Max>(
      fromFirestore: (snapshot, _) => Max.fromJson(snapshot.data()!),
      toFirestore: (max, _) => max.toJson(),
    );
    maxList.add(await data.get().then((value) => value.data()!));
  }
  return maxList;
}
  
void saveMax(Max max) {
  Map<String, Object?> jsonMax = max.toJson();
  firestoreInstance.collection("users").doc(userID).collection("maxes").add(jsonMax).then((value){
    print(value.id);
  }); 
}

void checkMax(Exercise exercise) async {
  // check if max already exists otherwise save
  final ref = await FirebaseFirestore.instance
  .collection('users')
  .doc(userID)
  .collection('maxes')
  .where('exercise', isEqualTo: exercise.name)
  .get();

  if (ref.docs.length == 0) {
    List setList = [];
    for (Sets set in exercise.sets) {
      // check which ones are maxes and which aren't
      if (setList.length > 0) {
        bool shouldUpdate = true;
        for (Sets newSet in setList) {
          if (newSet.reps == set.reps && newSet.weight == set.weight) {
            shouldUpdate = false;
          }
        }
        if (shouldUpdate) {
          setList.add(set);
        }
      } else {
        setList.add(set);
      }
    }
    for (Sets set in setList) {
      String date = DateTime.now().millisecondsSinceEpoch.toString();
      Max max = Max(set.weight, set.reps, set.sets, date, exercise.name);
      saveMax(max);
    }
  } else {

    List setList = [];
    for (Sets set in exercise.sets) {
      bool shouldUpdate = true;
      for (int i = 0; i < ref.docs.length; i++) {
        var data = ref.docs[i];

        if (data['reps'] == set.reps && data['weight'] == set.weight) {
          shouldUpdate = false;
        }
      }
      for (Sets refSet in setList) {
        if (set.reps == refSet.reps && set.weight == refSet.weight) {
          shouldUpdate = false;
        }
      }
      if (shouldUpdate) {
        setList.add(set);
      }
    }
    for (Sets set in setList) {
      String date = DateTime.now().millisecondsSinceEpoch.toString();
      Max max = Max(set.weight, set.reps, set.sets, date, exercise.name);
      saveMax(max);
    }
  }
}

void updateExercise(String id, Exercise exercise) {
  
}

  void printFirebase(){
    //
}