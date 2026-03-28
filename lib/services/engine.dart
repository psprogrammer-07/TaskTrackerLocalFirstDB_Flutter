import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crud_elf/db/dataBaseServices.dart';
import 'package:crud_elf/db/syncOperations.dart';
import 'package:hive/hive.dart';

class Engine {

  Databaseservices db =Databaseservices();
  Syncoperations so=Syncoperations();

  final _syncbox=Hive.box("sync-datas");


 Future<void> AddNewTask(Task newTask) async {
 
   await db.addTask(newTask);
   if(await CheckInternetConnection() ){
     
   await so.addTaskToBackend(newTask);

   }else{
        _syncbox.add( {
          "operation":"ADD",
          "task":newTask
        });
   }

  
 }

 Future<void> UpdateTask( Task updatedTask) async{
   db.updateTask(updatedTask);
    if(await CheckInternetConnection()){
   await so.syncUpdatedData(updatedTask);
    }else{

      _syncbox.add({
        "operation":"UPDATE",
        "task":updatedTask,
      });

    }
   
 }

 Future<void> DeleteTask(int taskId) async{
   db.deleteTask(taskId);

    if(await CheckInternetConnection() ){
      await so.SyncDeletedTask(taskId);
  
    }else{
      _syncbox.add({
        "operation":"DELETE",
        "taskId":taskId,
      });
    }
 }


 Future<void> mainSync() async{
    StreamSubscription<List<ConnectivityResult>> _networkSubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      
     
      if (results.contains(ConnectivityResult.wifi) || results.contains(ConnectivityResult.mobile)) {
        
        print("🌐 Network Restored! Triggering Background Sync...");


          for (int i = 0; i < _syncbox.length; i++) {
              var item = _syncbox.getAt(i);

              print("Processing: ${item['operation']}");

              bool isSuccess=false;

            

            if(item['operation']=="ADD"){
              print("The operation are equal add");
               isSuccess= await so.addTaskToBackend(item['task']);

              
            }              
            else if(item["operation"]=="UPDATE"){
              print("The operation are equal update");
               isSuccess= await so.syncUpdatedData(item["task"]);
              
            }
            else if(item["operation"]=="DELETE"){
              print("The operation are equal update");
               isSuccess= await so.SyncDeletedTask(item["taskId"]);
             
            }

            if(isSuccess){
               await _syncbox.deleteAt(i);
              i--;
            }
            else{
              break;
            }
          }

          await so.getTasks();

       
        
        
        
        
        
      } else if (results.contains(ConnectivityResult.none)) {
        print("🚫 Network Lost. Offline mode active.");
      }
    });
 }


Future<bool> CheckInternetConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');

   
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    print("internet not connected");
    return false;
  }
}

}
