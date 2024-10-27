import 'package:flutter/material.dart';

import 'models/department_model.dart';
import 'models/employee_model.dart';
import 'models/staff_model.dart';

final List<EmployeeModel> dummyEmployeeModels = [
  EmployeeModel(
    id: 1,
    email: 'john.doe@company.com',
    password: 'hashedPassword123',
    name: 'John Doe',
    phone: '(555) 123-4567',
    dob: DateTime(1985, 5, 15),
    age: 38,
    ssn: '123-45-6789',
    address: '123 Main St, New York, NY 10001',
    salary: 75000.00,
    role: 'Senior Developer',
    department: 'A',
    isManager: true,
  ),
  EmployeeModel(
    id: 2,
    email: 'jane.smith@company.com',
    password: 'hashedPassword456',
    name: 'Jane Smith',
    phone: '(555) 234-5678',
    dob: DateTime(1990, 8, 21),
    age: 33,
    ssn: '234-56-7890',
    address: '456 Oak Ave, Los Angeles, CA 90001',
    salary: 85000.00,
    role: 'Project Manager',
    department: 'B',
    isManager: true,
  ),
  EmployeeModel(
    id: 3,
    email: 'michael.johnson@company.com',
    password: 'hashedPassword789',
    name: 'Michael Johnson',
    phone: '(555) 345-6789',
    dob: DateTime(1988, 3, 10),
    age: 35,
    ssn: '345-67-8901',
    address: '789 Pine Rd, Chicago, IL 60601',
    salary: 65000.00,
    role: 'Developer',
    department: 'A',
  ),
  EmployeeModel(
    id: 4,
    email: 'sarah.williams@company.com',
    password: 'hashedPasswordABC',
    name: 'Sarah Williams',
    phone: '(555) 456-7890',
    dob: DateTime(1992, 11, 30),
    age: 31,
    ssn: '456-78-9012',
    address: '321 Elm St, Houston, TX 77001',
    salary: 70000.00,
    role: 'Designer',
    department: 'C',
  ),
  EmployeeModel(
    id: 5,
    email: 'robert.brown@company.com',
    password: 'hashedPasswordDEF',
    name: 'Robert Brown',
    phone: '(555) 567-8901',
    dob: DateTime(1983, 7, 4),
    age: 40,
    ssn: '567-89-0123',
    address: '654 Maple Dr, Seattle, WA 98101',
    salary: 90000.00,
    role: 'Technical Lead',
    department: 'D',
    isManager: true,
  ),
  EmployeeModel(
    id: 6,
    email: 'emily.davis@company.com',
    password: 'hashedPasswordGHI',
    name: 'Emily Davis',
    phone: '(555) 678-9012',
    dob: DateTime(1995, 1, 15),
    age: 28,
    ssn: '678-90-1234',
    address: '987 Cedar Ln, Boston, MA 02101',
    salary: 60000.00,
    role: 'Junior Developer',
    department: 'A',
  ),
  EmployeeModel(
    id: 7,
    email: 'david.wilson@company.com',
    password: 'hashedPasswordJKL',
    name: 'David Wilson',
    phone: '(555) 789-0123',
    dob: DateTime(1987, 9, 25),
    age: 36,
    ssn: '789-01-2345',
    address: '147 Birch Ave, Miami, FL 33101',
    salary: 72000.00,
    role: 'QA Engineer',
    department: 'B',
  ),
  EmployeeModel(
    id: 8,
    email: 'lisa.anderson@company.com',
    password: 'hashedPasswordMNO',
    name: 'Lisa Anderson',
    phone: '(555) 890-1234',
    dob: DateTime(1993, 4, 8),
    age: 30,
    ssn: '890-12-3456',
    address: '258 Walnut St, Denver, CO 80201',
    salary: 68000.00,
    role: 'Business Analyst',
    department: 'C',
  ),
];

final List<DepartmentModel> dummyDepartments = [
  DepartmentModel(
    name: 'A',
    managerId: 1, // John Doe
  ),
  DepartmentModel(
    name: 'B',
    managerId: 2, // Jane Smith
  ),
  DepartmentModel(
    name: 'C',
    managerId: null, // Currently no manager assigned
  ),
  DepartmentModel(
    name: 'D',
    managerId: 5, // Robert Brown
  ),
];

// First creating employee list that we'll use in staff
final List<EmployeeModel> dummyEmployees = [
  EmployeeModel(
      id: 1,
      email: 'john.doe@company.com',
      password: 'hashedPass123',
      name: 'John Doe',
      phone: '(555) 123-4567',
      dob: DateTime(1985, 5, 15),
      age: 38,
      ssn: '123-45-6789',
      address: '123 Main St, New York, NY 10001',
      salary: 75000.00,
      role: 'Senior Developer',
      department: 'A',
      isManager: true
  ),
  EmployeeModel(
      id: 2,
      email: 'jane.smith@company.com',
      password: 'hashedPass456',
      name: 'Jane Smith',
      phone: '(555) 234-5678',
      dob: DateTime(1990, 8, 21),
      age: 33,
      ssn: '234-56-7890',
      address: '456 Oak Ave, Los Angeles, CA 90001',
      salary: 85000.00,
      role: 'Project Manager',
      department: 'B',
      isManager: true
  ),
  EmployeeModel(
      id: 3,
      email: 'michael.johnson@company.com',
      password: 'hashedPass789',
      name: 'Michael Johnson',
      phone: '(555) 345-6789',
      dob: DateTime(1988, 3, 10),
      age: 35,
      ssn: '345-67-8901',
      address: '789 Pine Rd, Chicago, IL 60601',
      salary: 65000.00,
      role: 'Developer',
      department: 'A',
      isManager: false
  ),
  EmployeeModel(
      id: 4,
      email: 'sarah.williams@company.com',
      password: 'hashedPassABC',
      name: 'Sarah Williams',
      phone: '(555) 456-7890',
      dob: DateTime(1992, 11, 30),
      age: 31,
      ssn: '456-78-9012',
      address: '321 Elm St, Houston, TX 77001',
      salary: 70000.00,
      role: 'Designer',
      department: 'C',
      isManager: true
  ),
  EmployeeModel(
      id: 5,
      email: 'robert.brown@company.com',
      password: 'hashedPassDEF',
      name: 'Robert Brown',
      phone: '(555) 567-8901',
      dob: DateTime(1983, 7, 4),
      age: 40,
      ssn: '567-89-0123',
      address: '654 Maple Dr, Seattle, WA 98101',
      salary: 90000.00,
      role: 'Technical Lead',
      department: 'D',
      isManager: true
  ),
];

// List of Staff Models
final List<StaffModel> dummyStaffList = [
  StaffModel(
    staffId: 1,
    staffName: 'Development Team',
    department: 'A',
    managerList: [
      dummyEmployees[0], // John Doe
    ],
    empList: [
      dummyEmployees[0], // John Doe
      dummyEmployees[2], // Michael Johnson
    ],
  ),

  StaffModel(
    staffId: 2,
    staffName: 'Project Management Team',
    department: 'B',
    managerList: [
      dummyEmployees[1], // Jane Smith
    ],
    empList: [
      dummyEmployees[1], // Jane Smith
    ],
  ),

  StaffModel(
    staffId: 3,
    staffName: 'Design Team',
    department: 'C',
    managerList: [
      dummyEmployees[3], // Sarah Williams
    ],
    empList: [
      dummyEmployees[3], // Sarah Williams
    ],
  ),

  StaffModel(
    staffId: 4,
    staffName: 'Technical Team',
    department: 'D',
    managerList: [
      dummyEmployees[4], // Robert Brown
    ],
    empList: [
      dummyEmployees[4], // Robert Brown
    ],
  ),
];
