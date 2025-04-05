// ignore_for_file: unused_field, unused_import, prefer_final_fields
import 'dart:collection';
import 'package:fitpet_adventure/domain/models/community.dart';
import 'pet.dart';
import 'log.dart';

//A class that represents users of the app
class User{
  late final String _userId; //unique identifier of a user
  String _name = ""; //username must be unique
  String _email = ""; //email of the user(check format)
  String _bio = ""; 
  // String? _password;//holds hash of password
  int _currentStepCount = 0;
  List<User> _friends = []; //list of friends of user, add based on groups joined
  late Pet _pet; //the virtual pet of the user 
  List<Log> _logs = []; //logs of the user steps
  List<int> _joinedGroups = []; //id of groups user is part of
  //constructor
  User(String userId, String name, String email,  String bio, int currentStepCount){
    _userId = userId;
    _name = name;
    //check if email given is in proper format
    final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    if(emailValid){_email = email;} else{_email = "invalid email";}
    //user bio set later in profile
    _bio = bio;
    _currentStepCount = currentStepCount;
    _pet = Pet("", "", "", "", 1, 0);
  }

  set setName(String name){
    _name = name;
  }
  
  String get getName{
    return _name;
  }
  
  set setEmail(String email){
    //check if email given is in proper format
    final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    if(emailValid){_email = email;} else{_email = "invalid email";} //check content of email when saving it in database
  }
  
  String get getEmail{
    return _email;
  }
  
  set setBio(String bio){
    _bio = bio;
  }

  String get getBio{
    return _bio;
  }

  void incrementStep(int numSteps){
    if(numSteps >= 0){
      _currentStepCount = _currentStepCount + numSteps;
      //increment the users pet given numsteps
      _pet.incrementEvolutionBarpoints(numSteps);
    
    }
  }

  int get getCurrentStepCount{
    return _currentStepCount;
  }

  set setuserId(String userId){
    _userId = userId;
  }
  
  String get getuserId{
    return _userId;
  }

  bool addFriend(User aFriend){
    _friends.add(aFriend);
    return true;
  }

  bool? deleteFriend(User aFriend){
    return _friends.remove(aFriend);
    
  }

  List<User> get getFiends{
    return _friends;
  }

  set setPet(Pet pet){
    _pet = pet;
  }
  
  Pet get getPet{
    return _pet;
  }

  //log step count every 24hrs, needs to be fizex
  void addLog(Log aLog){
    _logs.add(aLog);
  }

  List<Log> get getLogs{
    return _logs;
  }

  void joinGroup(int groupId){
    _joinedGroups.add(groupId);
  }

  bool? eixtGroup(int groupId){
    return _joinedGroups.remove(groupId);
  }
}
