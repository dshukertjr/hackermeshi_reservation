import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tjpenwpeclvpsdtppxdx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqcGVud3BlY2x2cHNkdHBweGR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2Njg1MTEzMDYsImV4cCI6MTk4NDA4NzMwNn0.9Sm4RZT4iLfvvTaY2An-lHUQI96gtRtCa4pL_1VekGY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReservationPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          TextFormField(
            controller: _emailController,
          ),
          TextFormField(
            controller: _passwordController,
          ),
          ElevatedButton(
            onPressed: () async {
              final email = _emailController.text;
              final password = _passwordController.text;

              await supabase.auth.signUp(
                email: email,
                password: password,
              );

              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ReservationPage()));
            },
            child: const Text('登録'),
          ),
        ],
      ),
    );
  }
}

class ReservationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('予約')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('reservations').stream(primaryKey: ['id']),
        builder: ((context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          }
          final reservedTimeSlots = snapshot.data!
              .map(
                (row) => (int.parse((row['time_slot'] as String)
                    .split(',')
                    .first
                    .substring(1)
                    .split(' ')
                    .last
                    .substring(0, 2))),
              )
              .toList();

          return ListView.builder(
            itemBuilder: ((context, index) {
              return ListTile(
                tileColor: reservedTimeSlots.contains(index)
                    ? Colors.red
                    : Colors.white,
                title: Text(
                  index.toString(),
                  style: const TextStyle(fontSize: 36),
                ),
                onTap: () async {
                  try {
                    await supabase
                        .rpc('function_name', params: {'name': 'aaaa'});
                    await supabase.from('reservations').insert({
                      'time_slot':
                          '[2022-11-15 $index:00, 2022-11-15 ${index + 1}:00)',
                      'title': 'バーベキュー',
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('枠が埋まっています')));
                  }
                },
              );
            }),
            itemCount: 24,
          );
        }),
      ),
    );
  }
}
