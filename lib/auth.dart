import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class AuthService {
  final db = mongo.Db('mongodb://localhost:27017/Recite-Tool');

  Future<String?> register(String email, String password, String confirmPassword) async {
    if (!email.contains('@')) {
      return '请输入有效的邮箱地址';
    }
    if (password.length < 6) {
      return '密码长度不能少于6位';
    }
    if (password != confirmPassword) {
      return '两次输入的密码不一致';
    }
    
    try {
      if (!db.isConnected) {
        await db.open();
      }
      var collection = db.collection('users');
      
      // 检查邮箱是否已注册
      var existingUser = await collection.findOne({'email': email});
      if (existingUser != null) {
        return '该邮箱已被注册';
      }
      
      await collection.insert({
        'email': email, 
        'password': password,
        'createdAt': DateTime.now()
      });
      return null;
    } catch (e) {
      print('注册错误: $e');
      return '注册失败，请稍后再试';
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      if (!db.isConnected) {
        await db.open();
      }
      var collection = db.collection('users');
      var user = await collection.findOne({'email': email, 'password': password});
      return user != null;
    } catch (e) {
      print('登录错误: $e');
      return false;
    }
  }
}

class AuthWidget extends StatefulWidget {
  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _register() async {
    String? error = await _authService.register(
      _emailController.text, 
      _passwordController.text,
      _confirmPasswordController.text
    );
    
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('注册成功'))
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error))
      );
    }
  }

  void _login() async {
    bool success = await _authService.login(_emailController.text, _passwordController.text);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Login successful' : 'Login failed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户认证'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '登录'),
            Tab(text: '注册'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LoginForm(
            onSwitchToRegister: () => _tabController.animateTo(1),
            emailController: _emailController,
            passwordController: _passwordController,
            onLogin: _login,
          ),
          RegisterForm(
            onSwitchToLogin: () => _tabController.animateTo(0),
            emailController: _emailController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            onRegister: _register,
          ),
        ],
      ),
    );
  }
}
// 添加用户认证功能

class LoginForm extends StatefulWidget {
  final VoidCallback onSwitchToRegister;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;

  const LoginForm({
    super.key, 
    required this.onSwitchToRegister,
    required this.emailController,
    required this.passwordController,
    required this.onLogin
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: '邮箱'),
            controller: widget.emailController,
          ),
          TextField(
            decoration: const InputDecoration(labelText: '密码'),
            controller: widget.passwordController,
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: widget.onLogin,
            child: const Text('登录'),
          ),
          TextButton(
            onPressed: widget.onSwitchToRegister,
            child: const Text('没有账号？去注册'),
          ),
        ],
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onRegister;

  const RegisterForm({
    super.key, 
    required this.onSwitchToLogin,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onRegister
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: '邮箱'),
            controller: widget.emailController,
          ),
          TextField(
            decoration: const InputDecoration(labelText: '密码'),
            controller: widget.passwordController,
            obscureText: true,
          ),
          TextField(
            decoration: const InputDecoration(labelText: '确认密码'),
            controller: widget.confirmPasswordController,
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: widget.onRegister,
            child: const Text('注册'),
          ),
          TextButton(
            onPressed: widget.onSwitchToLogin,
            child: const Text('已有账号？去登录'),
          ),
        ],
      ),
    );
  }
}