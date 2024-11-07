import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  TextEditingController _leaveReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEmployeeData();
  }

  Future<void> _fetchLeaveRequests() async {
    try {
      // Fetch leave requests for staff (if manager)
      if (_data?['staff'] != null) {
        for (var staff in _data!['staff']) {
          if (staff['is_manager'] == 1) {
            final response = await http.get(
              Uri.parse('http://localhost/dbms/php/leave_requests.php?staff_id=${staff['staff_id']}'),
            );
            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              setState(() {
                _leaveRequests = List<Map<String, dynamic>>.from(data);
              });
            }
          }
        }
      }

      // Fetch employee's own leave requests
      if (_data?['employee'] != null) {
        final response = await http.get(
          Uri.parse('http://localhost/dbms/php/leave_requests.php?employee_id=${_data!['employee']['id']}'),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _myLeaveRequests = List<Map<String, dynamic>>.from(data);
          });
        }
      }
    } catch (e) {
      print('Error fetching leave requests: $e');
    }
  }

  Future<void> _createLeaveRequest(int staffId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/dbms/php/leave_requests.php'),
        body: jsonEncode({
          'employee_id': _data?['employee']?['id'],
          'staff_id': staffId,
          'reason': _leaveReasonController.text,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _leaveReasonController.clear();
          _fetchLeaveRequests();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
          );
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
    }
  }

  Future<void> _updateLeaveRequestStatus(int requestId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost/dbms/php/leave_requests.php'),
        body: jsonEncode({
          'request_id': requestId,
          'status': status,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        _fetchLeaveRequests();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Leave request $status'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error updating leave request: $e');
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
        content: TextField(
          controller: _leaveReasonController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter reason for leave',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Reason', request['reason']),
                        _buildDetailRow('Status', request['status']),
                        _buildDetailRow('Requested On', request['created_at']),
                      ],
                    ),
                  ),
                )).toList(),

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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Employee', request['employee_name']),
                          _buildDetailRow('Reason', request['reason']),
                          _buildDetailRow('Status', request['status']),
                          _buildDetailRow('Requested On', request['created_at']),
                          if (request['status'] == 'Pending')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => _updateLeaveRequestStatus(request['id'], 'Rejected'),
                                  child: Text('Reject'),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _updateLeaveRequestStatus(request['id'], 'Approved'),
                                  child: Text('Approve'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  )).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}