import 'package:crud_elf/db/dataBaseServices.dart';
import 'package:crud_elf/services/apiCalls.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {

  Apicalls ac= Apicalls();
  Databaseservices db=Databaseservices();

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
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Hive.box('tasksBox').get("mainData") == null) {
    db.loadInitialData();
  } else {
    db.loadTask();
  }
    myTasksFuture=  ac.getUserTasks();
  }

    void getData({int? index,String? category,String? task,String? description}) async{

      if(index!=null){
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
                  labelText: "Task Category",
                  border: OutlineInputBorder(), 
                  ),),
                  TextField(controller: _descText,
                  decoration: InputDecoration(
                  labelText: "Task Category",
                  border: OutlineInputBorder(), 
                  ),),
                ],

              ),
            ),


            actions: [
              TextButton(onPressed: ()async{

                if(index!=null){
                  await ac.updateTask(_categoryText.text.trim(), _taskText.text.trim(), _descText.text.trim(), index);
                }else{
                  await ac.postTask(_categoryText.text.trim(), _taskText.text.trim(), _descText.text.trim());
                }


                
               Navigator.pop(dialogContext); 

                // 3. REFRESH THE SCREEN HERE! (After the data is saved and dialog is closed)
              setState(() {
                myTasksFuture = ac.getUserTasks(); 
              });
                // 4. Clear the text boxes so they are empty for the next time
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
        onPressed: ()async{
          
          
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
                setState(() {
                   ac.deleteTask(taskId);
                });
                setState(() {
                  myTasksFuture=ac.getUserTasks();
                });
              }, icon: Icon(Icons.delete)),

              IconButton(onPressed:() async{
                setState(() {
                   getData(index:index,category: category,task: task,description: description);
                });
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