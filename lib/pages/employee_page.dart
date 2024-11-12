import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EmployeeDetails extends StatefulWidget {
  final String email;
  EmployeeDetails({required this.email});

  @override
  _EmployeeDetailsState createState() => _EmployeeDetailsState();
}

class _EmployeeDetailsState extends State<EmployeeDetails> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  List<Map<String, dynamic>> _leaveRequests = [];
  List<Map<String, dynamic>> _myLeaveRequests = [];
  List<Map<String, dynamic>> _leaveTypes = [];
  TextEditingController _leaveReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEmployeeData();
    _fetchLeaveTypes();
  }

  Future<void> _fetchLeaveTypes() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/dbms/php/leave_requests.php?leave_types=true'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _leaveTypes = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      }
    } catch (e) {
      print('Error fetching leave types: $e');
    }
  }

  Future<void> _fetchLeaveRequests() async {
    try {
      if (_data?['staff'] != null) {
        for (var staff in _data!['staff']) {
          if (staff['is_manager'] == 1) {
            final response = await http.get(
              Uri.parse('http://localhost/dbms/php/leave_requests.php?staff_id=${staff['staff_id']}'),
            );
            if (response.statusCode == 200) {
              setState(() {
                _leaveRequests = List<Map<String, dynamic>>.from(jsonDecode(response.body));
              });
            }
          }
        }
      }

      if (_data?['employee'] != null) {
        final response = await http.get(
          Uri.parse('http://localhost/dbms/php/leave_requests.php?employee_id=${_data!['employee']['id']}'),
        );
        if (response.statusCode == 200) {
          setState(() {
            _myLeaveRequests = List<Map<String, dynamic>>.from(jsonDecode(response.body));
          });
        }
      }
    } catch (e) {
      print('Error fetching leave requests: $e');
    }
  }

  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedLeaveTypeId;

  Future<void> _createLeaveRequest(int staffId) async {
    if (_startDate == null || _endDate == null || _selectedLeaveTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost/dbms/php/leave_requests.php'),
        body: jsonEncode({
          'employee_id': _data?['employee']?['id'],
          'staff_id': staffId,
          'reason': _leaveReasonController.text,
          'leave_type_id': _selectedLeaveTypeId,
          'start_date': DateFormat('yyyy-MM-dd').format(_startDate!),
          'end_date': DateFormat('yyyy-MM-dd').format(_endDate!),
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _leaveReasonController.clear();
          setState(() {
            _startDate = null;
            _endDate = null;
            _selectedLeaveTypeId = null;
          });
          _fetchLeaveRequests();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message']), backgroundColor: Colors.red),
          );
        }
      } else {
        throw Exception('Failed to create leave request');
      }
    } catch (e) {
      print('Error creating leave request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating leave request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Future<void> _fetchLeaveRequests() async {
  //   try {
  //     // Fetch leave requests for staff (if manager)
  //     if (_data?['staff'] != null) {
  //       for (var staff in _data!['staff']) {
  //         if (staff['is_manager'] == 1) {
  //           final response = await http.get(
  //             Uri.parse('http://localhost/dbms/php/leave_requests.php?staff_id=${staff['staff_id']}'),
  //           );
  //           if (response.statusCode == 200) {
  //             final data = jsonDecode(response.body);
  //             setState(() {
  //               _leaveRequests = List<Map<String, dynamic>>.from(data);
  //             });
  //           }
  //         }
  //       }
  //     }
  //
  //     // Fetch employee's own leave requests
  //     if (_data?['employee'] != null) {
  //       final response = await http.get(
  //         Uri.parse('http://localhost/dbms/php/leave_requests.php?employee_id=${_data!['employee']['id']}'),
  //       );
  //       if (response.statusCode == 200) {
  //         final data = jsonDecode(response.body);
  //         setState(() {
  //           _myLeaveRequests = List<Map<String, dynamic>>.from(data);
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     print('Error fetching leave requests: $e');
  //   }
  // }
  //
  // Future<void> _createLeaveRequest(int staffId) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://localhost/dbms/php/leave_requests.php'),
  //       body: jsonEncode({
  //         'employee_id': _data?['employee']?['id'],
  //         'staff_id': staffId,
  //         'reason': _leaveReasonController.text,
  //       }),
  //       headers: {'Content-Type': 'application/json'},
  //     );
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       if (data['success']) {
  //         _leaveReasonController.clear();
  //         _fetchLeaveRequests();
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text(data['message']), backgroundColor: Colors.red),
  //         );
  //       }
  //     } else {
  //       throw Exception('Failed to create leave request');
  //     }
  //   } catch (e) {
  //     print('Error creating leave request: $e');
  //   }
  // }

  // Future<void> _updateLeaveRequestStatus(int requestId, String status) async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse('http://localhost/dbms/php/leave_requests.php'),
  //       body: jsonEncode({
  //         'request_id': requestId,
  //         'status': status,
  //       }),
  //       headers: {'Content-Type': 'application/json'},
  //     );
  //     if (response.statusCode == 200) {
  //       _fetchLeaveRequests();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Leave request $status'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     }
  //     else{
  //       print(response.statusCode);
  //     }
  //   } catch (e) {
  //     print('Error updating leave request: $e');
  //   }
  // }

  Future<void> _updateLeaveRequestStatus(int requestId, String status) async {
    try {
      print('Updating request ${requestId} to ${status}'); // Debug log

      final response = await http.put(
        Uri.parse('http://localhost/dbms/php/leave_requests.php'),
        body: jsonEncode({
          'request_id': requestId.toString(), // Convert to string to ensure proper JSON encoding
          'status': status,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          await _fetchLeaveRequests(); // Refresh the leave requests
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Leave request $status'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception(responseData['message'] ?? 'Failed to update leave request');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update leave request');
      }
    } catch (e) {
      print('Error updating leave request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchEmployeeData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost/dbms/php/get_employee_data.php?email=${widget.email}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('error')) {
          throw Exception(data['error']);
        }
        setState(() {
          _data = data;
          _isLoading = false;
        });
        await _fetchLeaveRequests();
      } else {
        throw Exception('Failed to fetch employee data');
      }
    } catch (e) {
      print('Error fetching employee data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLeaveRequestDialog(int staffId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request Leave'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Start Date Picker
              ListTile(
                title: Text('Start Date'),
                subtitle: Text(_startDate == null
                    ? 'Select start date'
                    : DateFormat('yyyy-MM-dd').format(_startDate!)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (picked != null && picked != _startDate) {
                    setState(() {
                      _startDate = picked;
                      // If end date is before start date, update it
                      if (_endDate != null && _endDate!.isBefore(_startDate!)) {
                        _endDate = _startDate;
                      }
                    });
                  }
                },
              ),

              // End Date Picker
              ListTile(
                title: Text('End Date'),
                subtitle: Text(_endDate == null
                    ? 'Select end date'
                    : DateFormat('yyyy-MM-dd').format(_endDate!)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? _startDate ?? DateTime.now(),
                    firstDate: _startDate ?? DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (picked != null && picked != _endDate) {
                    setState(() {
                      _endDate = picked;
                    });
                  }
                },
              ),

              // Leave Type Dropdown
              DropdownButtonFormField<int>(
                value: _selectedLeaveTypeId,
                decoration: InputDecoration(
                  labelText: 'Leave Type',
                  border: OutlineInputBorder(),
                ),
                items: _leaveTypes.map((type) {
                  return DropdownMenuItem<int>(
                    value: int.parse(type['id'].toString()),
                    child: Text(type['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLeaveTypeId = value;
                  });
                },
              ),

              SizedBox(height: 16),

              // Reason TextField
              TextField(
                controller: _leaveReasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter reason for leave',
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Reset form data
              setState(() {
                _startDate = null;
                _endDate = null;
                _selectedLeaveTypeId = null;
                _leaveReasonController.clear();
              });
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate form
              if (_startDate == null ||
                  _endDate == null ||
                  _selectedLeaveTypeId == null ||
                  _leaveReasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _createLeaveRequest(staffId);
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(Map<String, dynamic> staff) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    staff['staff_name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    '${staff['member_count']} members',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
              ],
            ),
            SizedBox(height: 8),
            _buildDetailRow('Department', staff['department_name'] ?? 'N/A'),
            _buildDetailRow('Manager', staff['manager_name'] ?? 'N/A'),

            Divider(height: 24),

            Text(
              'Team Members',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),

            // Team members list
            ...((staff['members'] as List<dynamic>?) ?? []).map((member) =>
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Text(
                      member['name'][0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: member['is_manager'] == 1
                        ? Colors.orange
                        : Colors.blueGrey,
                  ),
                  title: Text(member['name']),
                  subtitle: Text(member['role']),
                  trailing: member['is_manager'] == 1
                      ? Chip(
                    label: Text('Manager', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.orange,
                  )
                      : null,
                ),
            ).toList(),

            if (staff['is_manager'] != 1)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () => _showLeaveRequestDialog(int.parse(staff['staff_id'])),
                  child: Text('Request Leave'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteEmployee(int employeeId) async {
    final String url = 'http://localhost/delete_employee.php';  // Replace with actual server URL

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'id': employeeId.toString(),  // Pass the employee ID as a POST parameter
        },
      );

      // Decode the response
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success']) {
        print(responseData['message']);
        // Optionally, show success message to user or refresh UI
      } else {
        print(responseData['message']);
        // Optionally, show error message to user
      }
    } catch (e) {
      print("Error: $e");
      // Optionally, show error message to user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () async {
        await deleteEmployee(_data!['employee']?['id']);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account deleted!')));
        Navigator.pop(context);
      }, child: Icon(Icons.delete),),
      appBar: AppBar(
        title: Text('Employee Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchEmployeeData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Employee Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employee Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildDetailRow('Name', _data?['employee']?['name']),
                      _buildDetailRow('Email', _data?['employee']?['email']),
                      _buildDetailRow('Phone', _data?['employee']?['phone']),
                      _buildDetailRow('Role', _data?['employee']?['role']),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Staff Assignments Section
              if (_data?['staff'] != null && _data!['staff'].isNotEmpty) ...[
                Text(
                  'Staff Assignments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 16),
                ..._data!['staff'].map<Widget>((staff) => _buildStaffCard(staff)).toList(),
              ],

              // My Leave Requests Section
              SizedBox(height: 24),
              Text(
                'My Leave Requests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 16),
              if (_myLeaveRequests.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('No leave requests found'),
                  ),
                )
              else
                ..._myLeaveRequests.map((request) => Card(
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                request['leave_type'] ?? 'Leave Request',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(request['status']),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                request['status'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Date Range
                        Row(
                          children: [
                            Icon(Icons.date_range, size: 20, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              'Duration:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${DateFormat('MMM dd, yyyy').format(DateTime.parse(request['start_date']))} - '
                                    '${DateFormat('MMM dd, yyyy').format(DateTime.parse(request['end_date']))} '
                                    '(${request['total_days']} days)',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        // Reason
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.description, size: 20, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              'Reason:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                request['reason'],
                                style: TextStyle(
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        // Request Date
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              'Requested:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              DateFormat('MMM dd, yyyy HH:mm').format(
                                  DateTime.parse(request['created_at'])
                              ),
                              style: TextStyle(
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )).toList(),

              // Manager's Leave Requests Section
              // In the build method, replace the existing leave requests review section with this updated version:

// Manager's Leave Requests Section
              if (_data?['staff']?.any((staff) => staff['is_manager'] == 1) ?? false) ...[
                SizedBox(height: 24),
                Text(
                  'Leave Requests to Review',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 16),
                if (_leaveRequests.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('No pending leave requests'),
                    ),
                  )
                else
                  ..._leaveRequests.map((request) => Card(
                    margin: EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  request['employee_name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(request['status']),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  request['status'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Leave Type
                          Row(
                            children: [
                              Icon(Icons.category, size: 20, color: Colors.grey[600]),
                              SizedBox(width: 8),
                              Text(
                                'Leave Type:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                request['leave_type'] ?? 'N/A',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),

                          // Date Range
                          Row(
                            children: [
                              Icon(Icons.date_range, size: 20, color: Colors.grey[600]),
                              SizedBox(width: 8),
                              Text(
                                'Duration:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${DateFormat('MMM dd, yyyy').format(DateTime.parse(request['start_date']))} - '
                                      '${DateFormat('MMM dd, yyyy').format(DateTime.parse(request['end_date']))} '
                                      '(${request['total_days']} days)',
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),

                          // Reason
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.description, size: 20, color: Colors.grey[600]),
                              SizedBox(width: 8),
                              Text(
                                'Reason:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  request['reason'],
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),

                          // Request Date
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
                              SizedBox(width: 8),
                              Text(
                                'Requested:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                DateFormat('MMM dd, yyyy HH:mm').format(
                                    DateTime.parse(request['created_at'])
                                ),
                                style: TextStyle(
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),

                          if (request['status'] == 'Pending') ...[
                            SizedBox(height: 16),
                            Divider(),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _updateLeaveRequestStatus(
                                      request['id'],
                                      'Rejected'
                                  ),
                                  icon: Icon(Icons.close, color: Colors.red),
                                  label: Text('Reject'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: BorderSide(color: Colors.red),
                                  ),
                                ),
                                SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: () => _updateLeaveRequestStatus(
                                      request['id'],
                                      'Approved'
                                  ),
                                  icon: Icon(Icons.check),
                                  label: Text('Approve'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  )).toList(),
              ],

// Add this helper method to your class

            ],
          ),
        ),
      ),
    );
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return Colors.green;
    case 'rejected':
      return Colors.red;
    case 'pending':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}