import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_realtimedb_crud/models/student_model.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

    DatabaseReference dbRef= FirebaseDatabase.instance.ref();

   final NameController =TextEditingController();
   final AgeController =TextEditingController();
   final SubjectController =TextEditingController();

   List<Student> studentList=[];
   
  bool updateStudent=false;

   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStudentData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Directory"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            for(int i=0;i<studentList.length;i++)
              studentWidget(studentList[i])

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          studentDialog();
        },
        child: Icon(Icons.add),
      ),
    );

    
  }

  // insert data
  void studentDialog({String?key}){
      showDialog(
        context: context,
         builder: (context){
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: NameController,
                    decoration: InputDecoration(
                      helperText: "Name",
                    ),
                  ),
                   TextField(
                    controller: AgeController,
                    decoration: InputDecoration(
                      helperText: "Age",
                    ),
                  ),
                   TextField(
                    controller: SubjectController,
                    decoration: InputDecoration(
                      helperText: "Subject",
                    ),
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: (){
                      Map<String,dynamic>data={
                        "name":NameController.text,
                        "age":AgeController.text,
                        "subject":SubjectController.text
                      };

                      //update data
                      if(updateStudent){
                        dbRef.child("Student").child(key!).update(data).then((value){
                          int index = studentList.indexWhere((element) => element.key==key);
                          studentList.removeAt(index);
                          studentList.insert(index, Student(key:key,studentData:StudentData.fromJson(data)));
                           setState(() {});
                          Navigator.of(context).pop();
                        });
                      }
                      else{
                         dbRef.child("Student").push().set(data).then((value) => {
                          Navigator.pop(context)
                        });
                      }
                    }, 
                    child: Text(updateStudent?"Update Data":"Save Data"),
                  ),
                ],
              ),
            ),
          );
         }
        );
    }
    
    //get data
    void getStudentData() {
      dbRef.child("Student").onChildAdded.listen((data) {
        StudentData studentData = StudentData.fromJson(data.snapshot.value as Map);
        Student student = Student(key: data.snapshot.key,studentData: studentData);
        studentList.add(student);
        setState(() {});
      });
    }

    // delete data
    void deleteData({String?key}){
      dbRef.child("Student").child(key!).remove().then((value){
          int index = studentList.indexWhere((element) => element.key==key);
          studentList.removeAt(index);
          setState(() {
            
          });
                  
       });
     }
    
     Widget studentWidget(Student studentList) {
      return InkWell(
        onTap: (){
        NameController.text = studentList.studentData!.name!;
       AgeController.text = studentList.studentData!.age!;
       SubjectController.text = studentList.studentData!.subject!;
      updateStudent = true;
        studentDialog(key: studentList.key);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.only(top:5,left: 10,right: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black)),
        child: Row(
          
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              
              children: [
                Text(studentList.studentData!.name!),
                Text(studentList.studentData!.age!),
                Text(studentList.studentData!.subject!),
              ],
            ),

            SizedBox(
              child: IconButton(
                onPressed: (){
                  deleteData(key:studentList.key);
                }, 
                icon: Icon(Icons.delete,color: Colors.red,),
                ),
            )
           
          ],
        ),
      ),
      );
     }

}