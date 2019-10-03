import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_tools/qr_code_tools.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cdr_today/widgets/refresh.dart';
import 'package:cdr_today/blocs/refresh.dart';
import 'package:cdr_today/navigations/args.dart';
import 'package:cdr_today/x/permission.dart' as pms;

class Scan extends StatefulWidget {
  @override
  _ScanState createState() => new _ScanState();
}

class _ScanState extends State<Scan> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.dark,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          child: Icon(
            Icons.close,
            color: Colors.white
          ),
          onTap: () => Navigator.maybePop(context),
        ),
        actions: [
          Center(
            child: QrRefresher(
              widget: GestureDetector(
                child: Icon(
                  Icons.photo_library,
                  color: Colors.white
                ),
                onTap: _pickImage
              ),
            ),
          ),
          SizedBox(width: 16.0),
        ],
        centerTitle: true,
      ),
      body: GestureDetector(
        child: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Colors.white,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: 300,
          ),
        ),
        onTap: () => controller?.toggleFlash(),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _pickImage() async {
    if (await pms.checkPhotos(context) == false) return;
    final _bloc = BlocProvider.of<RefreshBloc>(context);
    
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    _bloc.dispatch(Refresh(qr: true));
    String code = await QrCodeToolsPlugin.decodeFrom(image.path);
    if (code == null) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text('确定'),
                onPressed: () {
                  Navigator.pop(context);
                }
              ),
            ],
            title: Text('二维码识别失败，请重试'),
          );
        },
      );
    }

    Navigator.popAndPushNamed(
      context, '/qrcode/join',
      arguments: QrCodeArgs(
        code: code
      ),
    );

    _bloc.dispatch(Refresh(qr: false));
  }
  
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
        Navigator.pushNamed(
          context, '/qrcode/join',
          arguments: QrCodeArgs(
            code: scanData
          ),
        );
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
