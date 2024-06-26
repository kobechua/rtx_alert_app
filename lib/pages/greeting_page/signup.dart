import 'package:flutter/material.dart';
import 'package:rtx_alert_app/components/my_button.dart';
import 'package:rtx_alert_app/services/auth.dart';


class SignUpPage extends StatefulWidget {
  final Function()? onTap;
  const SignUpPage({super.key, this.onTap});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose(){
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    final FirebaseAuthService auth = FirebaseAuthService();

    void signUp() async {
      String email = emailController.text;
      String password = passwordController.text;
      String confirmPassword = confirmPasswordController.text;

      if (password.isEmpty){
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password cannot be empty.")));
      }
      else if (password != confirmPassword){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match.")));
      }
      else{
        try {
          await auth.signUpWithEmailAndPassword(email, password);
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ),
          );
        }
      }
    }


    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white24,
              Colors.black87,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        
        
              const Text("RTX Alert App", style: TextStyle(
                color: Colors.black, 
                fontSize:28.0, 
                fontWeight: FontWeight.bold,
                )
              ),
        
        
              const Text(
                "Sign Up Page",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 44.0,
                  fontWeight: FontWeight.bold
                ),
              ),
        
              //Email Field
              const SizedBox(        
                height: 21.0
              ),
        
        
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: emailController,
                  keyboardType:  TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "Email",
                    prefixIcon: Icon(Icons.mail, color: Colors.black)
                  )
                ),
              ),
        
              //Password Field
              const SizedBox(
                height: 28.0
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Password",
                  prefixIcon: Icon(Icons.password, color: Colors.black)
                )
              ),
        
              //Confirm Password Field
              const SizedBox(
                height: 28.0
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const  InputDecoration(
                  hintText: "Confirm Password",
                  prefixIcon: Icon(Icons.password, color: Colors.black)
                )
              ),
              const SizedBox(
                height: 28.0,
              ),
        
              // log in button
              MyButton(
                onTap: signUp,
                text: 'Create Account',
              ),
        
              const SizedBox(
                height: 15.0,
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?',
                  style: TextStyle(color: Colors.white),),
                  const SizedBox(width: 4),
                  
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.blue, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
