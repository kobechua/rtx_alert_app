import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'app_settings.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ignore: unused_field
  bool _isSettingEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSettingEnabled = prefs.getBool('settingEnabled') ?? false;
    });
  }

  Future<void> _updateSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settingEnabled', value);
    setState(() {
      _isSettingEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettings>(context, listen: false);
    

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.black87,
      ),

      body: ListTile(
        title: const Text(
          'Switch to English units',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),),
        trailing: Switch(
          value: appSettings.useEnglishUnits,
          activeTrackColor: Colors.black87,
          
          onChanged: (bool value) {
            appSettings.toggleUnitSystem();
            _updateSetting(value);
          },
        ),
      ),
    );
  }
}
