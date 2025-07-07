import 'package:flutter/material.dart';
import 'package:sms/pages/services/session_service.dart';
import 'package:sms/pages/session/edit_session.dart';
import 'package:sms/widgets/custom_appbar.dart'; // ✅ Make sure this path is correct

// ----------------- MODEL -----------------
class Session {
  final int id;
  final String sessionName;
  final String startDate;
  final String endDate;
  final bool isActive;

  Session({
    required this.id,
    required this.sessionName,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    String formatDate(String rawDate) {
      try {
        return DateTime.parse(rawDate)
            .toLocal()
            .toIso8601String()
            .split('T')[0];
      } catch (e) {
        return rawDate; // fallback
      }
    }

    return Session(
      id: json['id'],
      sessionName: json['session_name'],
      startDate: formatDate(json['start_date']),
      endDate: formatDate(json['end_date']),
      isActive: json['is_active'],
    );
  }
}

// ----------------- PAGE -----------------
class ManageSessionsPage extends StatefulWidget {
  const ManageSessionsPage({super.key});

  @override
  State<ManageSessionsPage> createState() => _ManageSessionsPageState();
}

class _ManageSessionsPageState extends State<ManageSessionsPage> {
  late Future<List<Session>> futureSessions;

  @override
  void initState() {
    super.initState();
    futureSessions = loadSessions();
  }

  Future<List<Session>> loadSessions() async {
    final result = await SessionService.getSessions();

    if (result['success'] == true) {
      final List<dynamic> sessionList = result['data'];
      return sessionList.map((json) => Session.fromJson(json)).toList();
    } else {
      throw Exception(result['message'] ?? 'Failed to fetch sessions');
    }
  }

  Future<void> deleteSession(int sessionId) async {
    final result = await SessionService.deleteSession(sessionId.toString());
    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session deleted successfully')),
      );
      setState(() {
        futureSessions = loadSessions();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message'] ?? 'Failed to delete session')),
      );
    }
  }

  void confirmDelete(int sessionId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Session"),
        content: Text("Are you sure you want to delete this session?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteSession(sessionId);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Manage Session'),
      body: FutureBuilder<List<Session>>(
        future: futureSessions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No sessions found'));
          }
          final sessions = snapshot.data!;
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      session.isActive
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: session.isActive ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      session.sessionName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        // Text('Name: ${session.sessionName}'),
                        Text('Start: ${session.startDate}'),
                        Text('End: ${session.endDate}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditSessionDialog(session: session),
                              ),
                            ).then((value) {
                              if (value == true) {
                                setState(() {
                                  futureSessions = loadSessions();
                                });
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => confirmDelete(session.id),
                        ),
                      ],
                    ),
                  ));
            },
          );
        },
      ),
    );
  }
}
