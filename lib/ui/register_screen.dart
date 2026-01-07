import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:urnicar/data/sync/pocketbase.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final studentIdController = TextEditingController();

  String? emailError;
  String? confirmPasswordError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    studentIdController.dispose();
    super.dispose();
  }

  void handleRegister() async {
    if (passwordController.text != confirmPasswordController.text) {
      setState(() => confirmPasswordError = 'Gesli se ne ujemata');
      return;
    }

    try {
      await pb
          .collection('users')
          .create(
            body: {
              'email': emailController.text,
              'password': passwordController.text,
              'passwordConfirm': confirmPasswordController.text,
              'name': nameController.text,
              'studentId': studentIdController.text,
            },
          );
    } on ClientException catch (e) {
      final fields = e.response['data'] as Map<String, dynamic>;
      for (final field in fields.entries) {
        if (field.key == 'email') {
          if (field.value['code'] == 'validation_not_unique') {
            setState(() => emailError = 'Uporabnik s tem e-mailom že obstaja');
          }
        }
      }
    }

    await pb
        .collection('users')
        .authWithPassword(emailController.text, passwordController.text);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registracija')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: emailError,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Geslo'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Potrdi geslo',
                errorText: confirmPasswordError,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Ime'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: studentIdController,
              decoration: const InputDecoration(labelText: 'Vpisna številka'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: handleRegister,
                child: const Text('Registracija'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pushReplacement('/register'),
              child: const Text('Nazaj na vpis'),
            ),
          ],
        ),
      ),
    );
  }
}
