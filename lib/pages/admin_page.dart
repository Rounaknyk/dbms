import 'package:dbms/constants.dart';
import 'package:dbms/models/employee_model.dart';
import 'package:dbms/models/staff_model.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  TextEditingController _staffNameController = TextEditingController();
  bool checkManager = false;
  String departmentName = '';
  String employeeName = '';
  List<EmployeeModel> addedEmpolyee = [];
  EmployeeModel? selectedEmployee = null;
  List<Widget> staffList = [];


  addStaffDialog(){
    showDialog(context: context, builder: (context){

      return StatefulBuilder(builder: (context, setStateDialog){

        return Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Staff Information', style: TextStyle(fontSize: 24),),
                          Spacer(),
                          InkWell(child: Icon(Icons.cancel_outlined, color: Colors.red, size: 30,), onTap: (){
                            Navigator.pop(context);
                          },),
                        ],
                      ),
                      SizedBox(height: 16,),
                      Container(
                        child: TextFormField(
                          controller: _staffNameController,
                          decoration: const InputDecoration(
                            labelText: 'Staff Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter staff name';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16.0,),
                      DropdownMenu(dropdownMenuEntries: dummyDepartments.map((e){

                        return DropdownMenuEntry(value: e.name, label: e.name);
                      }).toList(), hintText: 'Choose Department', onSelected: (value){
                        setState((){
                          departmentName = value!;
                        });
                        setStateDialog((){});
                      },),
                      SizedBox(height: 16.0,),
                      Row(
                        children: [
                          DropdownMenu(dropdownMenuEntries: dummyEmployeeModels.map((e){

                            return DropdownMenuEntry(value: e, label: e.name);
                          }).toList(),hintText: 'Choose Employee', onSelected: (value){

                            setState((){
                              selectedEmployee = value!;
                            });
                            setStateDialog((){});

                          },),
                          SizedBox(width: 16.0,),
                          Checkbox(value: checkManager, onChanged: (value){
                            print(value);
                            setState(() {
                              checkManager = value!;
                            });
                            setStateDialog((){});

                          },),
                          SizedBox(width: 8.0,),
                          Text('Manager'),
                          Spacer(),
                          ElevatedButton(onPressed: (){

                            if(selectedEmployee != null)
                              setState((){
                                selectedEmployee!.isManager = checkManager;
                                addedEmpolyee.add(selectedEmployee!);
                                Set<EmployeeModel> set = addedEmpolyee.toSet();

                                addedEmpolyee = set.toList();
                              });
                            setStateDialog((){});

                          }, child: Text('Add Employee'), ),
                        ],
                      ),
                      SizedBox(height: 16.0,),
                      Text('Added Employees: ', style: TextStyle(fontSize: 24),),
                      SizedBox(height: 16,),
                      ListView(
                        shrinkWrap: true,
                        children: addedEmpolyee.map((e){

                          return Card(child: ListTile(title: Text(e.name), trailing: InkWell(child: Icon(Icons.remove_circle, color: Colors.red,), onTap: (){
                            setState((){
                              addedEmpolyee.remove(e);
                            });
                            setStateDialog((){});

                          },), subtitle: Text(e.email),), color: e.isManager ? Colors.green : Colors.white,);
                        }).toList(),
                      ),
                      SizedBox(height: 16.0,),
                      InkWell(
                        onTap: (){
                          List<EmployeeModel> managerList = [];
                          for(var e in addedEmpolyee){
                            if(e.isManager)
                              managerList.add(e);
                          }
                          StaffModel sm = StaffModel(department: departmentName, empList: addedEmpolyee, managerList: managerList, staffId: DateTime.timestamp().millisecondsSinceEpoch, staffName: _staffNameController.text);
                          print(sm.toString());
                          // setState((){
                          //   staffList.add(sm);
                          // });
                          Size size = MediaQuery.of(context).size;

                          staffList.add(
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Material(
                                  elevation: 5,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: EdgeInsets.all(8.0),
                                    height: size.height * 0.3,
                                    width: size.width * 0.2,
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),),
                                    child: Center(child: Column(
                                      children: [
                                        Text('${sm.staffName}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                        Spacer(),
                                        Text('Staff ID: ${sm.staffId}'),
                                        SizedBox(height: 8.0,),
                                        Text('Department: ${sm.department}'),
                                        SizedBox(height: 8.0,),
                                        Text('Manager: ${sm.managerList.first.name}'),
                                        Spacer(),
                                      ],
                                    ),),
                                  ),
                                ),
                              )
                          );

                          setState(() {

                          });

                          print(staffList.length);
                          setStateDialog((){});
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12),),
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: Text('Save Staff', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),
                        ),
                      ),
                      SizedBox(height: 16.0,),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
    });
  }


  initCards(context) {
    Size size = MediaQuery.of(context).size;

    staffList.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: (){
          addStaffDialog();
        },
        child: Container(
          height: size.height * 0.3,
          width: size.width * 0.2,
          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12),),
          child: Center(child: Icon(Icons.add, color: Colors.white, size: 30,),),
        ),
      ),
    ),);

    staffList.addAll(dummyStaffList.map((e){
      Size size = MediaQuery.of(context).size;
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(8.0),
            height: size.height * 0.3,
            width: size.width * 0.2,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),),
            child: Center(child: Column(
              children: [
                Text('${e.staffName}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                Spacer(),
                Text('Staff ID: ${e.staffId}'),
                SizedBox(height: 8.0,),
                Text('Department: ${e.department}'),
                SizedBox(height: 8.0,),
                Text('Manager: ${e.managerList.first.name}'),
                Spacer(),
              ],
            ),),
          ),
        ),
      );
    }).toList());

    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initCards(context);
  }

  bool a = true;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    if(a) {
      staffList.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            addStaffDialog();
          },
          child: Container(
            height: size.height * 0.3,
            width: size.width * 0.2,
            decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(12),),
            child: Center(
              child: Icon(Icons.add, color: Colors.white, size: 30,),),
          ),
        ),
      ),);

      staffList.addAll(dummyStaffList.map((e) {
        Size size = MediaQuery
            .of(context)
            .size;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(8.0),
              height: size.height * 0.3,
              width: size.width * 0.2,
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12),),
              child: Center(child: Column(
                children: [
                  Text('${e.staffName}', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),),
                  Spacer(),
                  Text('Staff ID: ${e.staffId}'),
                  SizedBox(height: 8.0,),
                  Text('Department: ${e.department}'),
                  SizedBox(height: 8.0,),
                  Text('Manager: ${e.managerList.first.name}'),
                  Spacer(),
                ],
              ),),
            ),
          ),
        );
      }).toList());
    }
    a = false;
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){


      }),
      appBar: AppBar(title: Text('Admin Panel'), centerTitle: false,),
      drawer: Drawer(),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          child: Center(
            child: Wrap(
              children: staffList
            ),
          ),
        ),
      )),
    );
  }
}
