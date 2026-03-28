import 'package:crud_elf/db/syncOperations.dart';
import 'package:hive/hive.dart';

class Task {
  int taskId;
  String category;
  String task; 
  String description;
  

  Task({
    required this.taskId,
    required this.category,
    required this.task,
    required this.description,
  
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json["taskId"],
      category: json["category"],
      task: json["task"],
      description: json["description"],
    );
  }
}

   class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    return Task(
      taskId: reader.read(),
      category: reader.read(),
      task: reader.read(),
      description: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.write(obj.taskId);
    writer.write(obj.category);
    writer.write(obj.task);
    writer.write(obj.description);
  }
}

class Databaseservices {

  Databaseservices._privateConstructor();

  static final Databaseservices instance = Databaseservices._privateConstructor();

  factory Databaseservices() {
    return instance;
  }

  List<Task> localDb = []; 

  
  
  final _mybox = Hive.box("tasksBox");
  
   
  Future<void> addTask(Task newTask)async {
    loadTaskToLocalDB();
    localDb.add(newTask);
    updateDatabase();
  }

  void updateTask(Task newTask){
    for(Task data in localDb){
      if(data.taskId==newTask.taskId){
        data.category=newTask.category;
        data.task=newTask.task;
        data.description=newTask.description;

        break;

      }
    }
     updateDatabase();
     
     loadTaskToLocalDB();

  }

  void deleteTask(int taskId){
    for(Task data in localDb){

      if(data.taskId==taskId){
        localDb.remove(data);
        break;
      }

    }
    updateDatabase();
    loadTaskToLocalDB();

  }

  
  void loadTaskToLocalDB() {
   
    List<dynamic> rawData = _mybox.get("mainData", defaultValue: []);
    localDb = rawData.cast<Task>(); 
  }

  void loadInitialData() {
    localDb = [
      Task(taskId: 1, category: 'College', task: "First local task", description: "Created offline!"),
    ];
    updateDatabase();
  }

  
  void updateDatabase() {
    _mybox.put("mainData", localDb);
  }

  
}