// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pix_creator/inserevalor.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner:false,
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {



  final chavepix = TextEditingController();
  final merchantName = TextEditingController();
  final merchantCity = TextEditingController();
  String impressora="";
  @override
  void initState() {
    super.initState();

    _ler().then((data) {
      setState(() {
        _entrar();
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20), elevation: 2);
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuração inicial"),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: <Widget>[
          IconButton(onPressed: _ler, icon: Icon(Icons.refresh))
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25.0),
        child: Column(
          children: <Widget>[
            Icon(Icons.person_outline, size: 120.0, color: Colors.green),
            buildTextField("Chave Pix",chavepix,TextInputType.number),
            Divider(),
            buildTextField("Nome da Empresa",merchantName,TextInputType.text),
            Divider(),
            buildTextField("Cidade",merchantCity,TextInputType.text),

            Padding(
              padding: EdgeInsets.only(top: 25),
              child: ElevatedButton(
                onPressed: _gravar,
                style: style,
                child: const Text("Salvar"),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 25),
              child: ElevatedButton(
                onPressed: _entrar,
                style: style,
                child: const Text("ENTRAR"),
              ),
            )
          ],
        ),
      ),
    );
  }

  _entrar(){
    _ler;
    bool chave = chavepix.text=="";
    bool merchant = merchantName.text=="";
    bool city = merchantCity.text=="";
    if(!chave && !merchant && !city) {
      Navigator.of(context);
      Navigator.pop(context, ModalRoute.withName('/main'));
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) =>
              InsereValor(
                  chavepix.text,
                  merchantName.text,
                  merchantCity.text
              ))
      );
    }
  }

  _gravar() async {
    final pref = await SharedPreferences.getInstance();

    pref.setString("chavepix", chavepix.text.replaceAll(".", "").replaceAll("/", "").replaceAll("-", ""));
    pref.setString("merchantName", merchantName.text.toUpperCase().replaceAll(" ", ""));
    pref.setString("merchantCity", merchantCity.text.toUpperCase().replaceAll(" ", ""));

  }
  _ler() async {
   final pref = await SharedPreferences.getInstance();
   String chave = pref.getString("chavepix");
   String Name = pref.getString("merchantName");
   String City = pref.getString("merchantCity");
   String impressoralida = pref.getString("impressora");

  setState(() {
     chavepix.text = chave;
     merchantName.text = Name;
     merchantCity.text = City;
     impressora = impressoralida;
    });
  }

}
Widget buildTextField(String label,TextEditingController c,TextInputType tipo){
  return TextField(
    controller: c ,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: Colors.black
        ),
        border:OutlineInputBorder()
    ),
    style: TextStyle(
        color: Colors.black ,fontSize: 25.0
    ),
    keyboardType: tipo,
  );
}