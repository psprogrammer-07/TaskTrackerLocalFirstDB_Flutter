import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crud_elf/db/dataBaseServices.dart';
import 'package:crud_elf/db/syncOperations.dart';
import 'package:crud_elf/services/engine.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'dart:math';


class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {

 
  Databaseservices db=Databaseservices();
  Engine eg=Engine();

  late StreamSubscription<List<ConnectivityResult>> _networkSubscription;

  Future<List<dynamic>>? myTasksFuture;

  TextEditingController _categoryText=TextEditingController();
    TextEditingController _taskText=TextEditingController();
    TextEditingController _descText=TextEditingController();

    @override
  void dispose() {
    _categoryText.dispose();
    _taskText.dispose();
    _descText.dispose();
    super.dispose();
  }

@override
  void initState()  {
    // TODO: implement initState
    super.initState();
    

    eg.mainSync();
    
    
    if (Hive.box('tasksBox').get("mainData")==null) {
    db.loadInitialData();
  } else {
  
    
     db.loadTaskToLocalDB();
  
  }

  
    
  }

int generateUniqueId() {
  final now = DateTime.now().millisecondsSinceEpoch;
  int id=now % 4294967295;
  print("The generated task id:${id} ");
  return id; 
}

    void getData({int? taskid,String? category,String? task,String? description}) async{

      if(taskid!=null){
        _categoryText.text=category??"";
        _taskText.text=task??"";
        _descText.text=description??"";
      }
    
      showDialog(

        context: context,
        builder: (dialogContext) {
                  
          
          return AlertDialog(

            content: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,

                spacing: 10,

                children: [
                  TextField(controller: _categoryText,
                  decoration: InputDecoration(
                  labelText: "Task Category",
                  border: OutlineInputBorder(), 
                  ),
                  ),
                  TextField(controller: _taskText,
                  decoration: InputDecoration(
                  labelText: "Task Name",
                  border: OutlineInputBorder(), 
                  ),),
                  TextField(controller: _descText,
                  decoration: InputDecoration(
                  labelText: "discription",
                  border: OutlineInputBorder(), 
                  ),),
                ],

              ),
            ),


            actions: [
              TextButton(onPressed: ()async{

               if(taskid==null){
                  eg.AddNewTask(Task(taskId:generateUniqueId() , category: _categoryText.text.trim(), task: _taskText.text.trim(), description: _descText.text.trim()));
               }
               else{

               eg.UpdateTask(Task(taskId: taskid , category: _categoryText.text.trim(), task: _taskText.text.trim(), description: _descText.text.trim()));

               }

                
               Navigator.pop(dialogContext); 
                _categoryText.clear();
                _taskText.clear();
                _descText.clear();

              }, child: Text("ADD"))
            ],
            
          );
        },

      );
      
    }
  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsetsGeometry.all(15),
        child: Row(
          children: [
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box("tasksBox").listenable(),
                builder: (context, box, child) {
                 
                    List<dynamic> rawData = box.get("mainData", defaultValue: []);
                    List<Task> myTasks = rawData.cast<Task>();
                    if(myTasks.isEmpty){

                      return Center(child: Text("Task is empty"),);

                    }else{
                      return ListView.builder(
                      itemCount: myTasks.length,
                      itemBuilder: (context, index) {

                        return taskWidget(myTasks[index].category,myTasks[index].task,myTasks[index].description,index,myTasks[index].taskId);
                        
                      },
                    );
                    }

                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
                getData();
        },

        child: Icon(Icons.add),
      ),

    );
    
    
  }

  
  Widget taskWidget(String category,String task,String description,int index,int taskId){
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey,
        ),
        height: 120,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              
                  Text(category,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                  Text(task,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 24),),
                  Text(description,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
                    
                ],
              ),

              Row(
                children: [
                  IconButton(onPressed:() async{

                   
                    eg.DeleteTask(taskId);
                
              }, icon: Icon(Icons.delete)),

              IconButton(onPressed:() async{
                
                   getData(taskid:taskId,category: category,task: task,description: description);
                
              }, icon: Icon(Icons.settings)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}
