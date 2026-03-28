import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:crud_elf/db/dataBaseServices.dart';

class Syncoperations {

  Databaseservices db =Databaseservices();

 
  String get address => dotenv.env['address']??"";


  Future<void> getTasks()async{

    try{

        final url=Uri.parse("http://$address:3000/tasks");

        final res= await http.get(url);

        if(res.statusCode==200){
          print("Data successfully received");
          final data= jsonDecode(
            res.body
          );

          db.loadTaskToLocalDB();

          List<Task> localTasks= db.localDb;

          for(var receivedTask in data){
              bool isFinded=false;
              
            for(Task localTask in localTasks ){
               if(localTask.taskId== receivedTask['taskId']){
                 
                 isFinded=true;
                 break;
               }
            }
            if(!isFinded){
                Task newTask=Task.fromJson(receivedTask);
                 db.localDb.add(newTask);
                 isFinded=true;
                 db.updateDatabase();
            }

          }

        }else{
          print("Error on getTask api status code");
        }


    }catch(e){
      print("Error from getTask api");
    }

  }


  Future<bool> SyncDeletedTask(int taskId) async{

     
      

    try{
      final url= Uri.parse("http://$address:3000/task/sync-delete/$taskId");

      final res= await http.delete(url );

      if(res.statusCode==200){
        print("successfully sync the delete tasks");
        return true;
      }
      else{
        print("error on sync delete task , error status code");
        return false;
      }

    }
    catch(e){
      print("error on sync delete: $e");
      return false;
    }


  }



  Future<bool> syncUpdatedData(Task updateTask) async{
    db.loadTaskToLocalDB();

   

    try{
     final url= Uri.parse("http://$address:3000/task/sync-update/${updateTask.taskId}");

     final res= await http.put(url,
     
      headers: {"Content-Type":"application/json"},
      body: jsonEncode(
           {
            "updatedTask":{
              "category":updateTask.category,
              "task":updateTask.task,
              "description":updateTask.description
            },
           }
      )

     );

     if(res.statusCode==200){
      print("update sync successfully done");
      return true;
     }else{
      print("Error on sync update task on status code");
      return false;
     }
     

    }
    catch (e){
      print("error in syncupdatedata: $e");
      return false;
    }



  }

  
    

    Future<bool> addTaskToBackend(Task newTask)async{
       db.loadTaskToLocalDB();

        try{

      final url=Uri.parse("http://$address:3000/task/sync");

    
       
        final res= await http.post(url,
        
        headers: {"Content-Type":"application/json"},
        body: jsonEncode( {
          "unsyncTask": {
             "taskId": newTask.taskId,           // Added quotes around the keys
              "category": newTask.category,       // Added quotes
              "task": newTask.task,               // Added quotes
              "description": newTask.description, // Added quotes
          }
        })
        );


        if(res.statusCode==200){
          print("successfully upload the task to backend");


          db.updateDatabase();

          return true;
        }
        else{
          print("Error on upload task sync");
          return false;
        }

      }
      catch(e){
        print("Error in  sync post :$e");
        return false;
      }



    }



}
