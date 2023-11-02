import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Student {
  String documento;
  String nombres;
  int edad;

  Student({required this.documento, required this.nombres, required this.edad});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StudentList(),
    );
  }
}

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  List<Student> students = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudiantes'),
      ),
      body: StudentListView(
        students: students,
        onEdit: _navigateToStudentForm,
        onDelete: _deleteStudent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToStudentForm(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToStudentForm(Student? student) async {
    final newStudent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentForm(
            student: student,
            existingDocuments: students.map((s) => s.documento).toList()),
      ),
    );

    if (newStudent != null) {
      if (student == null) {
        setState(() {
          students.add(newStudent);
        });
      } else {
        final index = students.indexOf(student);
        setState(() {
          students[index] = newStudent;
        });
      }
    }
  }

  void _deleteStudent(Student student) {
    setState(() {
      students.remove(student);
    });
  }
}

class StudentListView extends StatelessWidget {
  final List<Student> students;
  final void Function(Student student) onEdit;
  final void Function(Student student) onDelete;

  const StudentListView({
    super.key,
    required this.students,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return ListTile(
          title: Text(student.nombres),
          subtitle:
              Text('Documento: ${student.documento} - Edad: ${student.edad}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  onEdit(student);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  onDelete(student);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class StudentForm extends StatefulWidget {
  final Student? student;
  final List<String> existingDocuments;

  const StudentForm({super.key, this.student, required this.existingDocuments});

  @override
  // ignore: library_private_types_in_public_api
  _StudentFormState createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final TextEditingController documentoController = TextEditingController();
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController edadController = TextEditingController();

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      documentoController.text = widget.student!.documento;
      nombresController.text = widget.student!.nombres;
      edadController.text = widget.student!.edad.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null
            ? 'Agregar Estudiante'
            : 'Editar Estudiante'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            TextField(
              controller: documentoController,
              decoration:
                  const InputDecoration(labelText: 'Documento de Identidad'),
              keyboardType: TextInputType.number, // Solo permite números
            ),
            TextField(
              controller: nombresController,
              decoration: const InputDecoration(labelText: 'Nombres'),
            ),
            TextField(
              controller: edadController,
              decoration: const InputDecoration(labelText: 'Edad'),
              keyboardType: TextInputType.number, // Solo permite números
            ),
            ElevatedButton(
              onPressed: () {
                final newDocumento = documentoController.text;
                if (widget.existingDocuments.contains(newDocumento)) {
                  setState(() {
                    errorMessage = "Documento ya existente";
                  });
                } else {
                  setState(() {
                    errorMessage = null;
                  });

                  final newStudent = Student(
                    documento: newDocumento,
                    nombres: nombresController.text,
                    edad: int.parse(edadController.text),
                  );
                  Navigator.pop(context, newStudent);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
