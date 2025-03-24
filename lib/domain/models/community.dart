// ignore_for_file: unused_field, unused_import
import 'dart:collection';
import 'user.dart';

//A class that represents the communities
class Group{
  late final int _groupId; //unique identifier of the group
  String _groupName = ""; //group name
  String _groupDescription = ""; //description of the group
  String _type = ""; //public or private
  List<User> _members = []; //user members of the group

  Group(int groupId, String groupName, String groupDescription, String type, List<User> members){
    _groupId = groupId;
    _groupName = groupName;
    _groupDescription = groupDescription;
    _type = type;
    _members = members;
  }

  set setgroupId(int groupId){
    _groupId = groupId;
  }
  
  int get getgroupId{
    return _groupId;
  }

  set setGroupName(String groupName){
    _groupName = groupName;
  }
  
  String get getGroupName{
    return _groupName;
  }

  set setGroupDescription(String groupDescription){
    _groupDescription = groupDescription;
  }
  
  String get getGroupdescription{
    return _groupDescription;
  }

  set setType(String type){
    _type = type;
  }
  
  String get getType{
    return _type;
  }

  bool addMembers(User aMember){
    _members.add(aMember);
    return true; //add way to verify member inserted
  }

  bool deleteMember(User aMember){
    return _members.remove(aMember);
  }

  List<User> get getMembers{
    return _members;
  }
}