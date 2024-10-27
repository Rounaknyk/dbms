import 'package:flutter/material.dart';

import 'employee_model.dart';

class StaffModel{

  List<EmployeeModel> empList = [];
  String staffName;
  String department;
  List<EmployeeModel> managerList;
  int staffId;

  StaffModel({required this.department, required this.empList, required this.managerList, required this.staffId, required this.staffName});

}