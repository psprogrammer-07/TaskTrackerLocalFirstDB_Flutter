import 'package:hive/hive.dart';

class Task {
  int taskId;
  String category;
  String task; // You named it 'task' here
  String description;
  bool isSynced;

  Task({
    required this.taskId,
    required this.category,
    required this.task,
    required this.description,
    this.isSynced = false,
  });
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
      isSynced: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.write(obj.taskId);
    writer.write(obj.category);
    writer.write(obj.task);
    writer.write(obj.description);
    writer.write(obj.isSynced);
  }
}

class Databaseservices {
  List<Task> localDb = []; 
  
  
  final _mybox = Hive.box("tasksBox"); 

  
  void loadTask() {
   
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