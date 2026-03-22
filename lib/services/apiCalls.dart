import 'dart:convert';
import 'dart:core';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Apicalls {
  String get address => dotenv.env['address']??"";
    Future<List<dynamic>> getUserTasks()async{

    final url=Uri.parse("http://$address:3000/get-tasks");

    final res=await http.get(url);


    try{

      if(res.statusCode==200){
        var data= jsonDecode(res.body);
        
        return data;
      }
      else{
        print("status code error");
        return[];
      }

    }
    catch(e){
      print(e);
      return [];
    }
  }

  Future<bool> postTask(String category,String task,String description) async{

    final url=Uri.parse("http://$address:3000/post-task");

    try{

    final res= await http.post(url,
    
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
        {
            "category":category,
            "task":task,
            "description":description
        }
      ),
    );

    if(res.statusCode==201){
      print("successfully posted the data");
      return true;
    }
    else{
      print("error in status code");
      return false;
    }

    

    }catch(e){
      print("error on post: $e");
      return false;
    }


  }

  Future<void> updateTask(String category,String task,String description,int index)async{

    final url=Uri.parse("http://$address:3000/update-task/$index");

    try{

      final res= await http.put(url,
      
      headers: {"Content-Type":"application/json"},
      body: jsonEncode(
          {
            "category":category,
            "task":task,
            "description":description,
          }
      ),

      );

      if(res.statusCode==200){
        print("updated successfully");
      }
      else{
        print("error on error code");
      }

      

    }catch(e){
      print("error on put: $e");
    }

  }

  Future<void> deleteTask(int id) async{

    final url=Uri.parse("http://$address:3000/delete-task/$id");

    try{

      final res=await http.delete(url);

      if(res.statusCode==200){
        print("sucessfully delete the task");
      }
      else{
        print("error on delete function");
      }
      
    }
    catch(e){
      print("error on delete: $e");
    }

  }
  
}
