import 'dart:typed_data';
import 'package:ffi_to_d/wallet_provider.dart';

void main(List<String> arguments) {
  bool created = false;
  List<int> pinCode = [1, 1, 1, 1];
  String questionsStr = 'q1;q2;q3;q4';
  String answersStr = 'a1;a2;a3;a4';
  int confidence = 4;
  int aesKeyDocId = 0;
  WalletProvider provider = WalletProvider();

  /// Lib func call.
  final result = provider.createWallet(Uint8List.fromList(pinCode), aesKeyDocId, questionsStr, answersStr, confidence);
  print(result.toString());

  if (result.recoveryBuffer.isNotEmpty) {
    created = true;
  }
  print(created);
}
