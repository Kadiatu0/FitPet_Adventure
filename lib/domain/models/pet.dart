// ignore_for_file: unused_field, unused_import
import 'dart:collection';

//A class that represents the virtual pets
class Pet{
  late final String _petId; //unique identifier of a user 
  String _petName = ""; //username must be unique
  String _petDescription = ""; //description of the pet
  String _petType = ""; //Water, Earth, Sky, Space
  int _evolutionLevel = 1; //current evolution level of the pet
  int _evolutionBarpoints = 0; //current evolution points of pet, only changed through steps of user

  Pet(String petId, String petName, String petDescription, String petType, int evolutionLevel, int evolutionBarpoints){
    _petId = petId;
    _petName = petName;
    _petDescription = petDescription;
    _petType = petType;
    //evolution starts at level 1, make sure it starts at 1
    if(evolutionLevel == 1){ _evolutionLevel = evolutionLevel;} else{_evolutionLevel = 1;}
    _evolutionBarpoints = evolutionBarpoints; //correct to make sure it is within range, and set throught num of steps
  }

  set setPetName(String petName){
    _petName = petName;
  }
  
  String get getPetName{
    return _petName;
  }

  set setPetId(String petId){
    _petId = petId;
  }
  
  String get getPetId{
    return _petId;
  }

  set setPetDescription(String petDescription){
    _petDescription = petDescription;
  }
  
  String get getPetDescription{
    return _petDescription;
  }
  
  set setPetType(String petType){
    _petType = petType;
  }
  
  String get getPetType{
    return _petType;
  }

  set setEvolutionLevel(int evolutionLevel){ //sets the intial evolution level
    if(evolutionLevel == 1){ _evolutionLevel = evolutionLevel;} else{_evolutionLevel = 1;}
  }

  void incrementEvolutionLevel(){
    if(_evolutionLevel < 3){
      _evolutionLevel = _evolutionLevel + 1;
    }
  }
  
  int get getEvolutionLevel{
    return _evolutionLevel;
  }

  void incrementEvolutionBarpoints(int steps){
    _evolutionBarpoints = _evolutionBarpoints + steps;
  }
  
  int? get getevolutionBarpoints{
    return _evolutionBarpoints;
  }

}
