import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main(){
  runApp(chat_page());
}

class chat_page extends StatelessWidget {
  const chat_page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: chat_page_sub(),);
  }
}

class chat_page_sub extends StatefulWidget {
  const chat_page_sub({Key? key}) : super(key: key);

  @override
  State<chat_page_sub> createState() => _chat_page_subState();
}

class _chat_page_subState extends State<chat_page_sub> {
  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String b = prefs.getString("lid").toString();
    String foodimage="";
    var data =
    await http.post(Uri.parse(prefs.getString("ip").toString()+"/user_view_reply"),
        body: {"id":b}
    );

    var jsonData = json.decode(data.body);
//    print(jsonData);
    List<Joke> jokes = [];
    for (var joke in jsonData["message"]) {
      print(joke);
      Joke newJoke = Joke(
          joke["id"].toString(),
          joke["complaint"],
          joke["complaint_date"].toString(),
          joke["reply"].toString(),
          joke["reply_date"].toString()
      );
      jokes.add(newJoke);
    }
    return jokes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(

        child:
        FutureBuilder(
          future: _getJokes(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
//              print("snapshot"+snapshot.toString());
            if (snapshot.data == null) {
              return Container(
                child: Center(
                  child: Text("Loading..."),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  var i = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            SizedBox(height: 10),
                            _buildRow("Date:", i.complaint_date.toString()),
                            _buildRow("Complaint:", i.complaint.toString()),
                            _buildRow("Reply:", i.reply.toString()),
                            _buildRow("Date:", i.reply_date.toString()),

                          ],
                        ),
                      ),
                    ),
                  );
                },
              );


            }
          },


        ),





      ),



    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }



}




class Joke {
  final String id;
  final String complaint;

  final String complaint_date;
  final String reply;
  final String reply_date;




  Joke(this.id,this.complaint, this.complaint_date,this.reply,this.reply_date);
//  print("hiiiii");
}































