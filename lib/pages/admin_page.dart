import 'dart:async';

import 'package:dbms/constants.dart';
import 'package:dbms/models/employee_model.dart';
import 'package:dbms/models/staff_model.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class StaffService {
  static Future<bool> createStaff(StaffModel staff) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}staff_creation.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'staffId': staff.staffId,
          'staffName': staff.staffName,
          'department': staff.department,
          'employees': staff.empList.map((emp) => {
            'employee_id': emp.id,
            'isManager': emp.isManager,
          }).toList(),
        }),
      );

      final data = jsonDecode(response.body);
      return data['status'] == 'success';
    } catch (e) {
      print('Error creating staff: $e');
      return false;
    }
  }
// New method to get all staff
  static Future<List<StaffModel>> getAllStaff() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}get_staff.php'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Add this line

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return (data['data'] as List).map((staffData) {
          List<EmployeeModel> employees = [];
          for (var emp in staffData['employees']) {
            print(emp['employee_id']);
            employees.add(EmployeeModel(
              id: emp['employee_id'],
              isManager: emp['isManager'], email: emp['email'], password: emp['password'], name: emp['name'], phone: emp['phome'].toString(), dob: emp['dob'], age: emp['age'], ssn: emp['ssn'], address: emp['address'], salary: emp['salary'], role: emp['role'],
              // You may need to add other fields based on your EmployeeModel
            ));
          }
          return StaffModel(
            staffId: int.parse(staffData['staffId'].toString()),
            staffName: staffData['staffName'],
            department: staffData['department'],
            empList: employees,
            managerList: employees.where((e) => e.isManager).toList(),
          );
        }).toList();
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      print('Error fetching staff: $e');
      return [];
    }
  }
}


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
                        onTap: () async {
                          List<EmployeeModel> managerList = [];
                          for(var e in addedEmpolyee){
                            if(e.isManager)
                              managerList.add(e);
                          }

                          StaffModel sm = StaffModel(
                              department: departmentName,
                              empList: addedEmpolyee,
                              managerList: managerList,
                              staffId: DateTime.timestamp().millisecondsSinceEpoch,
                              staffName: _staffNameController.text
                          );

                          // Save to database
                          final success = await StaffService.createStaff(sm);

                          if (success) {
                            setState(() {
                              staffList.add(
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Material(
                                      elevation: 5,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: EdgeInsets.all(8.0),
                                        height: MediaQuery.of(context).size.height * 0.3,
                                        width: MediaQuery.of(context).size.width * 0.2,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Text(
                                                '${sm.staffName}',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                              Spacer(),
                                              Text('Staff ID: ${sm.staffId}'),
                                              SizedBox(height: 8.0),
                                              Text('Department: ${sm.department}'),
                                              SizedBox(height: 8.0),
                                              Text('Manager: ${sm.managerList.first.name}'),
                                              Spacer(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                              );
                            });
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Staff created successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to create staff'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Save Staff',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
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

  bool isLoading = false;

  Future<void> loadStaffData() async {
    setState(() {
      isLoading = true;
      staffList.clear();
    });

    // Add the "Add Staff" card first
    staffList.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            addStaffDialog();
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width * 0.2,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final staffData = await StaffService.getAllStaff();

      final staffWidgets = staffData.map((staff) =>
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 0.2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        staff.staffName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      Text('Staff ID: ${staff.staffId}'),
                      const SizedBox(height: 8.0),
                      Text('Department: ${staff.department}'),
                      const SizedBox(height: 8.0),
                      if (staff.managerList.isNotEmpty)
                        Text('Manager: ${staff.managerList.first.name}')
                      else
                        const Text('No Manager Assigned'),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ).toList();

      setState(() {
        staffList.addAll(staffWidgets);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading staff data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 1), (){
      loadStaffData();
    });

    // initCards(context);
  }

  bool a = true;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){
        loadStaffData();
      }),
      appBar: AppBar(title: Text('Admin Panel'), centerTitle: false,),
      drawer: Drawer(),
      body: isLoading ? Center(child: CircularProgressIndicator(color: Colors.black,),) : SafeArea(child: Padding(
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
