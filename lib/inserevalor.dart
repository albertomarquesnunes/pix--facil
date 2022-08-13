// @dart=2.9
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pix_creator/Cobrar.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<Map> getData(String chave,String beneficiario,String cidade,String descricao, String valor) async {
  final uri = 'http://www.primesolutions.com.br/pix/geradorqr.php';
  var map = new Map<String, dynamic>();
  map['chave'] = chave;
  map['beneficiario'] = beneficiario;
  map['cidade'] = cidade;
  map['descricao'] = descricao;
  map['valor'] = valor;

  http.Response response = await http.post(
    uri,
    body: map,
  );

  return jsonDecode(response.body);
}

class InsereValor extends StatefulWidget {
  InsereValor( this.chavepix,
  this.merchantName, this.merchantCity);

  /* Esse é o creator que vai receber os dados */

  final String chavepix;
  final String merchantName;
  final String merchantCity;

  @override
  _InsereValorState createState() => _InsereValorState();
}
class _InsereValorState extends State<InsereValor>{
  final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), elevation: 2);
  TextEditingController valorController = TextEditingController();
  TextEditingController pedidoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    valorController.text ="";
    pedidoController.text ="";

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preencher valor"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(10.0),
    child: Column(
        children: <Widget>[
          Divider(),
          buildTextField("Pedido Número",pedidoController,TextInputType.number,FilteringTextInputFormatter.deny(RegExp(r'[,.-]'))),
          Divider(),
          buildTextField("Valor com os Centavos",valorController,TextInputType.number,FilteringTextInputFormatter.deny(RegExp(r'[,-]'))),
          Divider(),
          Padding(
            padding: EdgeInsets.only(top: 25),
            child: ElevatedButton(
              onPressed: _Cobrar,
              style: style,
              child: const Text("ENTRAR"),
            ),
          )

        ]
    )
    )
    );
  }

  _Cobrar() async {
    /* setState(() {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });*/
    if (valorController.text!='') {
      var decoded = await getData(
          widget.chavepix.replaceAll(".", "").replaceAll("/", "").replaceAll("-", ""),
          widget.merchantName.replaceAll(" ", "").toUpperCase(), widget.merchantCity.replaceAll(" ", ""),
          pedidoController.text, valorController.text.replaceAll(",", "."));
      if (decoded['Resp'] == '1') {
        String pix = decoded['pix'];
        print("pagina inserevalor pix decoded:"+pix);


        Navigator.of(context);

        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) =>
                Cobrar(
                    widget.chavepix,
                    widget.merchantName,
                    widget.merchantCity,
                    pedidoController.text,
                    valorController.text, pix)
        )
        );
      }
      else
      {
        _apagar;
      }
    }

  }

  _apagar() async{
    final pref = await SharedPreferences.getInstance();
    pref.remove("chavepix");
    pref.remove("merchantName");
    pref.remove("merchantCity");
    pref.remove("impressora");
  }

}



Widget buildTextField(String label,TextEditingController c,TextInputType tipo, TextInputFormatter proibido){
  return TextField(
    controller: c ,
    keyboardType: tipo,
    inputFormatters: [proibido],
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


  );
}
String numberValidator(String value) {
  if (value == null) {
    return null;
  }
  final n = num.tryParse(value);
  if(n == null) {
    return '"$value" is not a valid number';
  }
  return null;
}