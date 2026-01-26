

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2bill/screens/login_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'theme/colors.dart';
import 'theme/theme.dart';
// 1. IMPORT YOUR CUSTOM WIDGET HERE
import 'widgets/app_button.dart';

const List<Color> _blobGradient1 = AppColors.blobGradient1;
const List<Color> _blobGradient2 = AppColors.blobGradient2;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void changeTheme(BuildContext context) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeTheme();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _mode = ThemeService.instance.isDarkMode
      ? ThemeMode.dark
      : ThemeMode.light;



  void changeTheme() {
    setState(() {
      ThemeService.instance.toggle();
      _mode = ThemeService.instance.isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _mode,

      home: const MyApp_sub(),
    );
  }
}

class MyApp_sub extends StatefulWidget {
  const MyApp_sub({Key? key}) : super(key: key);

  @override
  State<MyApp_sub> createState() => _MyApp_subState();
}

class _MyApp_subState extends State<MyApp_sub> {
  TextEditingController ip = TextEditingController(text: "10.39.218.28");
  // TextEditingController ip = TextEditingController(text: "192.168.29.5");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark?AppColors.iconColorDark:AppColors.iconColorLight;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        //extend the body to be visible in the back of appbar
        extendBodyBehindAppBar: true,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Container(
              padding: EdgeInsets.all(5),

              decoration: BoxDecoration(
                color: AppColors.greyButton.withValues(alpha:0.5),
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                icon: Icon(
                  ThemeService.instance.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color:iconColor,
                ),
                onPressed: () {
                  MyApp.changeTheme(context);
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Positioned(
                top: -70,
                left: -50,
                child: _buildBlob(250, _blobGradient1),
              ),
              Positioned(
                top: 150,
                right: -80,
                child: _buildBlob(180, _blobGradient2),
              ),


              Column(

                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),

                  Center(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),

                      ),
                      margin: const EdgeInsets.all(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 40,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.transparent,
                                child: SvgPicture.asset('assets/images/snap2bill_logo.svg',height:100,)),
                            SizedBox(height: 10,),
                            Text(
                              "Enter Your IP Address",

                              style: TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 20,
                              ),
                            ),

                            const SizedBox(height: 20),
                            TextFormField(
                              controller: ip,
                              style: TextStyle(
                                color: ThemeService.instance.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              decoration: InputDecoration(
                                labelText: 'IP Address',
                                prefixIcon: const Icon(Icons.wifi),
                                prefixIconColor: iconColor,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ------------------------------------------------
                            // 2. HERE IS YOUR NEW CUSTOM BUTTON
                            // ------------------------------------------------
                            AppButton(
                              text: "Submit",
                              // icon: Icons.upload,
                              // isTrailingIcon: true,
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString("ip", "http://${ip.text}:8000");

                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(),
                                    ),
                                  );
                                }
                              },
                            ),

                            // ------------------------------------------------
                          ],
                        ),
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

Widget _buildBlob(double size, List<Color> colors) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  );
}
