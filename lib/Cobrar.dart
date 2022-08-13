// @dart=2.9
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pix_creator/Imprime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:telephony/telephony.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

class Cobrar extends StatefulWidget { Cobrar( this.chavepix, this.merchantName,
      this.merchantCity, this.pedido, this.valor, this.pix);

  final String chavepix;
  final String merchantName;
  final String merchantCity;
  final String pedido;
  final String valor;
  final String pix;

  @override
  _CobrarState createState() => _CobrarState();
}

class _CobrarState extends State<Cobrar>{
  final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20), elevation: 2);
  String _message = "";
  final telephony = Telephony.instance;
  BluetoothConnection connection;
  bool isDisconnecting = false;
  String impressora;
  bool get isConnected => connection != null && connection.isConnected;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _ler().then((data) {
      setState(() {
        print('dados da impressora '+data);
       impressora  = data;
      });
    });
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
      RegExp exp = new RegExp( "\\b" + widget.valor + "\\b", caseSensitive: false, );
      print("mensagem = "+_message);
      bool resposta = exp.hasMatch(_message);

      //banco safra: Pix recebido de eduardo e monica valor de R$ 1,80. detalhes
      print("resposta = "+resposta.toString());
      if(resposta){
        print("imprimiu");
        _imprimir(_message,"0");
      }
    });
  }
  Future<String> initPlatformState() async {
    final bool result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);

    }

    if (!mounted) {return 'false';}else{return 'true';}
  }


  @override
  Widget build(BuildContext context) {
    print("tela cobrar pix = " + widget.pix);
    return Scaffold(
      appBar: AppBar(
        title: Text("Leia o Código QR"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(60.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 0),

            ),
            SizedBox(height: 30,),

            QrImage(
              data: widget.pix,
              gapless: true,
              size: 240,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.only(top: 25),
              child: ElevatedButton(
                onPressed: (){
                  _imprimir("Impressão Manual","1");
                },
                style: style,
                child: const Text("Imprime Manualmente"),
              ),
            )

          ],

        ),
      ),
    );
  }
   _ler() async {
    print("ler entrou");
    String impressora ;
    final pref = await SharedPreferences.getInstance();
    impressora = pref.getString("impressora") ;

    if(impressora==null){
      Navigator.of(context);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) =>
              Imprime(widget.merchantName)
      )
      );
    }
    _connect(impressora);
    print("Lido "+impressora);
    return impressora;

  }
    _imprimir(String mensagem,String modo) async {

      print("impressora: "+ impressora.toString());

      if(impressora==null){
       Navigator.of(context);

          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  Imprime(widget.merchantName)
          )
          );
        }
     else
       {// (ESC)\x1B\x33\x1B\x21\x08
        connection.output.add(utf8.encode(" ****** Pix Rapido ****** " + "\r\n\n"));
       // connection.output.add(utf8.encode(widget.merchantName+"\r\n\n"));
        connection.output.add(utf8.encode("Recibo de compra numero "+widget.pedido + "\r\n\n"));
        connection.output.add(utf8.encode(mensagem + "\r\n\n"));
        connection.output.add(utf8.encode("Valor pago R\u0024 :"+widget.valor + "\r\n"));
        connection.output.add(utf8.encode("\r\n"));
      if(modo=="1") {
        connection.output.add(utf8.encode("RECIBO IMPRESSO MANUALMENTE \r\n"));
        connection.output.add(utf8.encode("\r\n"));
      }
        connection.output.add(utf8.encode("AJR Sistemas de Cobranca" + "\r\n\n\n"));
        await connection.output.allSent;
        print('Device Turned On');

    }
  }
  void _connect(_device) async {

    if (_device == null) {
      print('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
        /*  setState(() {
            _connected = true;

          });*/

          connection.input.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        print('Device connected');

       // setState(() => _isButtonUnavailable = false);
      }
    }
  }
}
