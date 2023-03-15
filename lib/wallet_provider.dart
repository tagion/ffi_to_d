import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'd_memory_doc.dart';
import 'tagion_lib_provider.dart';

class WalletCreateResult {
  final List<int> _recoveryBuffer;
  final List<int> _devicePinBuffer;
  final List<int> _accountBuffer;

  List<int> get recoveryBuffer => _recoveryBuffer;
  List<int> get devicePinBuffer => _devicePinBuffer;
  List<int> get accountBuffer => _accountBuffer;

  bool get isEmpty => accountBuffer.isEmpty;

  WalletCreateResult(
      this._recoveryBuffer, this._devicePinBuffer, this._accountBuffer);

  @override
  String toString() {
    return 'recoveryBuffer $recoveryBuffer , devicePinBuffer $devicePinBuffer , accountBuffer $accountBuffer';
  }
}

/// Provides methods for wallet interaction.
class WalletProvider {
  /// Tagion library provider.
  final LibProvider _libProvider = LibProvider();

  LibProvider get libProvider => _libProvider;

  static final WalletProvider _walletProvider = WalletProvider._internal();

  WalletProvider._internal() {
    /// Start D runtime.
    _libProvider.startRuntime();
  }

  factory WalletProvider() {
    return _walletProvider;
  }

  int basic_create_wallet(Uint8List pinCode, int aesKeyDocId, String questions,
      String answers, int confidence) {
    final Pointer<Uint8> pinCodePtr = this.getPointer(pinCode);
    final Pointer<Utf8> questionsPtr = questions.toNativeUtf8();
    final Pointer<Utf8> answersPtr = answers.toNativeUtf8();

    /// Get a length from pointers above.
    final int pinCodeLen = pinCode.length;
    final int questionsLen = questionsPtr.length;
    final int answersLen = answersPtr.length;

    int responseId = _libProvider.walletCreate(
        pinCodePtr,
        pinCodeLen,
        aesKeyDocId,
        questionsPtr,
        questionsLen,
        answersPtr,
        answersLen,
        confidence);

    return responseId;
  }

  /// Params that should be passed in:
  /// [pinCode] String,
  /// [questions] String,
  /// [answers] String,
  /// [confidence] int.
  WalletCreateResult createWallet(Uint8List pinCode, int aesKeyDocId,
      String questions, String answers, int confidence) {
    /// Create a pointers from passed in data.

    final Pointer<Uint8> pinCodePtr = this.getPointer(pinCode);
    final Pointer<Utf8> questionsPtr = questions.toNativeUtf8();
    final Pointer<Utf8> answersPtr = answers.toNativeUtf8();

    /// Get a length from pointers above.
    final int pinCodeLen = pinCode.length;
    final int questionsLen = questionsPtr.length;
    final int answersLen = answersPtr.length;

    /// Claim wallet id after it's creation.
    int responseId = _libProvider.walletCreate(
        pinCodePtr,
        pinCodeLen,
        aesKeyDocId,
        questionsPtr,
        questionsLen,
        answersPtr,
        answersLen,
        confidence);

    /// Create a document based on wallet id.
    final DMemoryDoc responseDoc = DMemoryDoc.fromId(responseId);

    int recoveryDocId = responseDoc.getInt('recovery');
    int devPinDocId = responseDoc.getInt('pin');
    int accountDocId = responseDoc.getInt('account');

    final DMemoryDoc recoveryDoc = DMemoryDoc.fromId(recoveryDocId);
    final DMemoryDoc devPinDoc = DMemoryDoc.fromId(devPinDocId);
    final DMemoryDoc accountDoc = DMemoryDoc.fromId(accountDocId);

    /// Get buffers value.
    final List<int> recoveryBuffer = recoveryDoc.buffer;
    final List<int> devicePinBuffer = devPinDoc.buffer;
    final List<int> accountBuffer = accountDoc.buffer;

    responseDoc.dispose();
    recoveryDoc.dispose();
    devPinDoc.dispose();
    accountDoc.dispose();

    return WalletCreateResult(recoveryBuffer, devicePinBuffer, accountBuffer);
  }

  /// Params that should be passed in:
  /// [pinCode] String,
  /// [questions] String,
  /// [answers] String,
  /// [confidence] int.
  // WalletCreateResult restoreWallet(
  //     List<int> recoveryFile, Uint8List pinCode, int aesKeyId, String questions, String answers) {
  //   /// Create a pointers from passed in data.
  //   final DMemoryDoc oldRecoveryDoc = DMemoryDoc.fromBuffer(recoveryFile);

  //   final Pointer<Uint8> pinCodePtr = this.getPointer(pinCode);
  //   final Pointer<Utf8> questionsPtr = questions.toNativeUtf8();
  //   final Pointer<Utf8> answersPtr = answers.toNativeUtf8();

  //   /// Get a length from pointers above.

  //   final int pinCodeLen = pinCode.length;
  //   final int questionsLen = questionsPtr.length;
  //   final int answersLen = answersPtr.length;

  //   /// Claim wallet id after it's creation.
  //   int responseId = _libProvider.walletRestore(
  //       oldRecoveryDoc.docId, pinCodePtr, pinCodeLen, aesKeyId, questionsPtr, questionsLen, answersPtr, answersLen);

  //   if (responseId == 0) return WalletCreateResult([], [], []);

  //   /// Create a document based on wallet id.
  //   final DMemoryDoc responseDoc = DMemoryDoc.fromId(responseId);

  //   int recoveryDocId = responseDoc.getInt('recovery');
  //   int devPinDocId = responseDoc.getInt('pin');
  //   int accountDocId = responseDoc.getInt('account');

  //   final DMemoryDoc recoveryDoc = DMemoryDoc.fromId(recoveryDocId);
  //   final DMemoryDoc devPinDoc = DMemoryDoc.fromId(devPinDocId);
  //   final DMemoryDoc accountDoc = DMemoryDoc.fromId(accountDocId);

  //   /// Get buffers value.
  //   final List<int> recoveryBuffer = recoveryDoc.buffer;
  //   final List<int> devicePinBuffer = devPinDoc.buffer;
  //   final List<int> accountBuffer = accountDoc.buffer;

  //   oldRecoveryDoc.dispose();
  //   responseDoc.dispose();
  //   recoveryDoc.dispose();
  //   devPinDoc.dispose();
  //   accountDoc.dispose();

  //   return WalletCreateResult(recoveryBuffer, devicePinBuffer, accountBuffer);
  // }

  // /// Creates invoice based on existing [walletId], provided by user [pinCode] and [amount].
  // /// Returns invoice id.
  // Future<List<int>> createInvoice(
  //     List<int> wallet, List<int> devicePin, Uint8List pinCode, int aesKeyDocId, int amount) async {
  //   final String metaInfo = 'Payment Request';

  //   /// Create pointers.
  //   final Pointer<Uint8> pinCodePtr = this.getPointer(pinCode);
  //   final Pointer<Utf8> metaInfoPtr = metaInfo.toNativeUtf8();

  //   /// Get length from each pointer.
  //   final int metaInfoLen = metaInfoPtr.length;
  //   final int pinCodeLen = pinCode.length;

  //   /// Create wallet doc from the buffer.
  //   DMemoryDoc walletDoc = DMemoryDoc.fromBuffer(wallet);

  //   /// Create device pin doc from the buffer.
  //   DMemoryDoc devPinDoc = DMemoryDoc.fromBuffer(devicePin);

  //   /// Create invoice.
  //   /// Claim invoice id.
  //   int invoiceId = _libProvider.invoiceCreate(
  //       walletDoc.docId, devPinDoc.docId, pinCodePtr, pinCodeLen, aesKeyDocId, amount, metaInfoPtr, metaInfoLen);

  //   /// Create a document based on invoice id.
  //   final DMemoryDoc invoiceDoc = DMemoryDoc.fromId(invoiceId);

  //   final List<int> invoiceBuffer = invoiceDoc.buffer;

  //   /// Dispose docs.
  //   walletDoc.dispose();
  //   devPinDoc.dispose();
  //   invoiceDoc.dispose();

  //   return invoiceBuffer;
  // }

  // /// Creates contract based on existing [walletId], [invoiceId], provided [pinCode] by user.
  // Future<List<int>> createContract(List<int> wallet, List<int> devicePin, List<int> invoiceBuffer, Uint8List pinCode,
  //     int aesKeyDocId, int amount) async {
  //   /// Create pointers.
  //   final Pointer<Uint8> pinCodePtr = this.getPointer(pinCode);

  //   /// Get length from each pointer.
  //   final int pinCodeLen = pinCode.length;

  //   /// Create a doc from the wallet buffer.
  //   DMemoryDoc walletDoc = DMemoryDoc.fromBuffer(wallet);

  //   /// Create a doc from the device pin buffer.
  //   DMemoryDoc devPinDoc = DMemoryDoc.fromBuffer(devicePin);

  //   /// Create a doc from the invoice buffer.
  //   DMemoryDoc invoiceDoc = DMemoryDoc.fromBuffer(invoiceBuffer);

  //   /// Create contract.
  //   /// Claim contract id.
  //   int contractId = _libProvider.contractCreateWithAmount(
  //       walletDoc.docId, devPinDoc.docId, invoiceDoc.docId, pinCodePtr, pinCodeLen, aesKeyDocId, amount);

  //   /// Create a document based on contract id.
  //   final DMemoryDoc contract = DMemoryDoc.fromId(contractId);

  //   final List<int> contractBuffer = contract.buffer;

  //   /// Dispose docs.
  //   walletDoc.dispose();
  //   devPinDoc.dispose();
  //   invoiceDoc.dispose();
  //   contract.dispose();

  //   return contractBuffer;
  // }

  // /// Creates contract based on existing [wallet], [pubKey], provided [pinCode] by user.
  // Future<List<int>> createContractWithPubKey(
  //   List<int> wallet,
  //   List<int> devicePin,
  //   Uint8List pubKey,
  //   Uint8List pinCode,
  //   int aesKeyDocId,
  //   int amount,
  // ) async {
  //   /// Create pointers.
  //   final Pointer<Uint8> pinCodePtr = this.getPointer(pinCode);
  //   final Pointer<Uint8> pubKeyPtr = this.getPointer(pubKey);

  //   /// Get length from each pointer.
  //   final int pinCodeLen = pinCode.length;
  //   final int pubKeyLen = pubKey.length;

  //   /// Create a doc from the wallet buffer.
  //   DMemoryDoc walletDoc = DMemoryDoc.fromBuffer(wallet);

  //   /// Create a doc from the device pin buffer.
  //   DMemoryDoc devPinDoc = DMemoryDoc.fromBuffer(devicePin);

  //   /// Create contract.
  //   /// Claim contract id.
  //   int contractId = _libProvider.contractCreateWithPubKey(
  //       walletDoc.docId, devPinDoc.docId, pubKeyPtr, pubKeyLen, pinCodePtr, pinCodeLen, aesKeyDocId, amount);

  //   if (contractId == 0) throw ContractError('Contract create failed');

  //   /// Create a document based on contract id.
  //   final DMemoryDoc contract = DMemoryDoc.fromId(contractId);

  //   final List<int> contractBuffer = contract.buffer;

  //   /// Dispose docs.
  //   walletDoc.dispose();
  //   devPinDoc.dispose();
  //   contract.dispose();

  //   return contractBuffer;
  // }

  // /// Use on each contract/invoice send.
  // List<int> getDerivers(List<int> wallet, List<int> devicePin, Uint8List pinCode, int aesKeyDocId) {
  //   /// Create pointers.
  //   final Pointer<Uint8> pinCodePtr = this.getPointer(pinCode);

  //   /// Get length from each pointer.
  //   final int pinCodeLen = pinCode.length;

  //   /// Create a doc from the wallet buffer.
  //   DMemoryDoc walletDoc = DMemoryDoc.fromBuffer(wallet);

  //   /// Create a doc from the device pin buffer.
  //   DMemoryDoc devPinDoc = DMemoryDoc.fromBuffer(devicePin);

  //   int deriversDocId = libProvider.getDerivers(walletDoc.docId, devPinDoc.docId, pinCodePtr, pinCodeLen, aesKeyDocId);

  //   DMemoryDoc deriversDoc = DMemoryDoc.fromId(deriversDocId);

  //   List<int> deriversBuffer = deriversDoc.buffer;

  //   /// Dispose docs.
  //   walletDoc.dispose();
  //   devPinDoc.dispose();
  //   deriversDoc.dispose();

  //   return deriversBuffer;
  // }

  // /// Use only on wallet restoration.
  // Future<bool> setDerivers(
  //     List<int> wallet, List<int> devicePin, List<int> derivers, Uint8List pinCode, int aesKeyDocId) async {
  //   /// Create pointers.
  //   final Pointer<Uint8> pinCodePtr = this.getPointer(pinCode);

  //   /// Get length from each pointer.
  //   final int pinCodeLen = pinCode.length;

  //   /// Create a doc from the wallet buffer.
  //   DMemoryDoc walletDoc = DMemoryDoc.fromBuffer(wallet);

  //   /// Create a doc from the device pin buffer.
  //   DMemoryDoc devPinDoc = DMemoryDoc.fromBuffer(devicePin);

  //   /// Create a doc from the derivers buffer.
  //   DMemoryDoc deriversDoc = DMemoryDoc.fromBuffer(derivers);

  //   int result = libProvider.setDerivers(
  //     walletDoc.docId,
  //     devPinDoc.docId,
  //     pinCodePtr,
  //     pinCodeLen,
  //     aesKeyDocId,
  //     deriversDoc.docId,
  //   );

  //   /// Dispose docs.
  //   walletDoc.dispose();
  //   devPinDoc.dispose();
  //   deriversDoc.dispose();

  //   return result == 1;
  // }

  // Future<bool> addDerivers(
  //   List<int> wallet,
  //   List<int> devicePin,
  //   String derivers,
  //   Uint8List pinCode,
  //   int aesKeyDocId,
  // ) async {
  //   /// Create pointers.
  //   final Pointer<Uint8> pinCodePtr = this.getPointer(pinCode);

  //   final Pointer<Utf8> deriversPtr = derivers.toNativeUtf8();

  //   /// Get length from each pointer.
  //   final int pinCodeLen = pinCode.length;

  //   final int deriversLen = derivers.length;

  //   /// Create a doc from the wallet buffer.
  //   DMemoryDoc walletDoc = DMemoryDoc.fromBuffer(wallet);

  //   /// Create a doc from the device pin buffer.
  //   DMemoryDoc devPinDoc = DMemoryDoc.fromBuffer(devicePin);

  //   int result = libProvider.addDerivers(
  //       walletDoc.docId, devPinDoc.docId, pinCodePtr, pinCodeLen, deriversPtr, deriversLen, aesKeyDocId);

  //   /// Dispose docs.
  //   walletDoc.dispose();
  //   devPinDoc.dispose();

  //   return result == 1;
  // }

  // List<int> getPublicKey(List<int> wallet, List<int> devicePin, Uint8List pinCode, int aesKeyDocId) {
  //   /// Create pointers.
  //   final Pointer<Uint8> pinCodePtr = this.getPointer(pinCode);

  //   /// Get length from each pointer.
  //   final int pinCodeLen = pinCode.length;

  //   /// Create a doc from the wallet buffer.
  //   DMemoryDoc walletDoc = DMemoryDoc.fromBuffer(wallet);

  //   /// Create a doc from the device pin buffer.
  //   DMemoryDoc devPinDoc = DMemoryDoc.fromBuffer(devicePin);

  //   int responseDocId = libProvider.getPubKey(walletDoc.docId, devPinDoc.docId, pinCodePtr, pinCodeLen, aesKeyDocId);

  //   /// Create a document based on wallet id.
  //   final DMemoryDoc responseDoc = DMemoryDoc.fromId(responseDocId);

  //   List<int> publicKeyBuffer = responseDoc.getBuffer('result');

  //   /// Dispose docs.
  //   walletDoc.dispose();
  //   devPinDoc.dispose();
  //   responseDoc.dispose();

  //   return publicKeyBuffer;
  // }

  // /// Retrieves wallet public keys.
  // List<BillContainer> getWalletPubKeys(List<int> walletBuffer) {
  //   final String billsTag = '\$bills';

  //   /// Public key tag.
  //   final String pKeyTag = '\$Y';

  //   return getPubKeys(walletBuffer, billsTag, pKeyTag);
  // }

  // /// Retrieves contract public keys from "out" section.
  // List<BillContainer> getContractOutputPubKeys(List<int> contractBuffer) {
  //   final String messageTag = '\$msg';
  //   final String paramsTag = 'params';
  //   final String innerContractTag = '\$contract';
  //   final String pubKeysTag = '\$out';

  //   /// Found pub keys.
  //   final List<BillContainer> result = [];

  //   /// Get a document by its buffer.
  //   final DMemoryDoc document = DMemoryDoc.fromBuffer(contractBuffer);

  //   final DMemoryDoc message = document.getInnerDoc(messageTag);

  //   final DMemoryDoc params = message.getInnerDoc(paramsTag);

  //   final DMemoryDoc innerContract = params.getInnerDoc(innerContractTag);

  //   final DMemoryDoc pubKeys = innerContract.getInnerDoc(pubKeysTag);

  //   result.add(BillContainer(pubKeys.getBuffer('0'), 0));

  //   document.dispose();
  //   message.dispose();
  //   params.dispose();
  //   innerContract.dispose();
  //   pubKeys.dispose();

  //   return result;
  // }

  // /// Retrieves contract public keys from "in" section.
  // List<BillContainer> getContractInputPubKeys(List<int> contractBuffer) {
  //   final String messageTag = '\$msg';
  //   final String paramsTag = 'params';
  //   final String billsTag = '\$in';

  //   /// Public key tag.
  //   final String pKeyTag = '\$Y';

  //   /// Get a document by its buffer.
  //   final DMemoryDoc document = DMemoryDoc.fromBuffer(contractBuffer);

  //   final DMemoryDoc message = document.getInnerDoc(messageTag);

  //   final DMemoryDoc params = message.getInnerDoc(paramsTag);

  //   List<int> paramsBuffer = params.buffer;

  //   document.dispose();
  //   message.dispose();
  //   params.dispose();

  //   return getContractPubKeys(paramsBuffer, billsTag, pKeyTag);
  // }

  // List<int> getInvoicePubKey(List<int> invoiceBuffer) {
  //   final String billTag = '0';

  //   /// Public key tag.
  //   final String pKeyTag = 'pkey';

  //   late DMemoryDoc document;
  //   late DMemoryDoc bill;

  //   try {
  //     /// Get a document by id.
  //     document = DMemoryDoc.fromBuffer(invoiceBuffer);

  //     /// Get bills document.
  //     bill = document.getInnerDoc(billTag);

  //     /// Get bill.
  //     List<int> pubKey = bill.getBuffer(pKeyTag);

  //     return pubKey;
  //   } catch (e) {
  //     return [];
  //   } finally {
  //     bill.dispose();
  //     document.dispose();
  //   }
  // }

  // /// Retrieves wallet's public keys. Returns a list of binaries.
  // List<BillContainer> getContractPubKeys(List<int> buffer, String billsTag, String pKeyTag) {
  //   /// Found pub keys.
  //   final List<BillContainer> result = [];

  //   late DMemoryDoc document;
  //   late DMemoryDoc bills;
  //   try {
  //     /// Get a document by id.
  //     document = DMemoryDoc.fromBuffer(buffer);

  //     /// Get bills document.
  //     bills = document.getInnerDoc(billsTag);

  //     /// Get bills count.
  //     final int billsCount = bills.getMembersCount();

  //     /// Iterate bills and add to result array.
  //     for (int i = 0; i < billsCount; i++) {
  //       /// Get bill.
  //       DMemoryDoc bill = bills.getInnerDoc('$i');

  //       List<int> pubKey;
  //       int amount;
  //       try {
  //         /// Get bill buffer.
  //         pubKey = bill.getBuffer(pKeyTag);

  //         /// Get bill's amount.
  //         amount = bill.getLong('\$V');
  //       } catch (e) {
  //         continue;
  //       } finally {
  //         /// Delete bill doc from the memory.
  //         bill.dispose();
  //       }

  //       /// Add to result array.
  //       result.add(BillContainer(pubKey, amount));
  //     }
  //   } catch (e) {
  //     return result;
  //   } finally {
  //     document.dispose();
  //     bills.dispose();
  //   }

  //   return result;
  // }

  // /// Retrieves wallet's public keys. Returns a list of binaries.
  // List<BillContainer> getPubKeys(List<int> buffer, String billsTag, String pKeyTag) {
  //   /// Found pub keys.
  //   final List<BillContainer> result = [];

  //   late DMemoryDoc document;
  //   late DMemoryDoc bills;
  //   try {
  //     /// Get a document by id.
  //     document = DMemoryDoc.fromBuffer(buffer);

  //     /// Get bills document.
  //     bills = document.getInnerDoc(billsTag);

  //     /// Get bills count.
  //     final int billsCount = bills.getMembersCount();

  //     /// Iterate bills and add to result array.
  //     for (int i = 0; i < billsCount; i++) {
  //       /// Get bill.
  //       DMemoryDoc billWrapper = bills.getInnerDoc('$i');

  //       DMemoryDoc bill = billWrapper.getInnerDoc('\$b');

  //       List<int> pubKey;
  //       int amount;
  //       try {
  //         /// Get bill buffer.
  //         pubKey = bill.getBuffer(pKeyTag);

  //         /// Get bill's amount.
  //         amount = bill.getLong('\$V');
  //       } catch (e) {
  //         continue;
  //       } finally {
  //         /// Delete bill doc from the memory.
  //         billWrapper.dispose();
  //         bill.dispose();
  //       }

  //       /// Add to result array.
  //       result.add(BillContainer(pubKey, amount));
  //     }
  //   } catch (e) {
  //     return result;
  //   } finally {
  //     document.dispose();
  //     bills.dispose();
  //   }

  //   return result;
  // }

  // /// Returns a buffer that could be passed in network request.
  // Future<OperationResult> getWalletUpdateRequest(List<int> walletBuffer) async {
  //   /// Create a wallet doc from the buffer.
  //   DMemoryDoc walletDoc = DMemoryDoc.fromBuffer(walletBuffer);

  //   /// Get request id for wallet update.
  //   final int requestId = _libProvider.getRequestUpdateWallet(walletDoc.docId);

  //   /// Create a doc from request id.
  //   final DMemoryDoc requestDoc = DMemoryDoc.fromId(requestId);

  //   final List<int> requestBuffer = requestDoc.buffer;

  //   requestDoc.dispose();
  //   walletDoc.dispose();

  //   /// Retrieve and return a result buffer.
  //   return OperationResult.onSuccess<List<int>>(requestBuffer);
  // }

  // /// Updates a wallet with a new data. Return a boolean as an operation status.
  // Future<OperationResult> setWalletUpdateResponse(
  //     List<int> wallet, List<int> responseBuffer, List<int> devicePin, Uint8List pinCode, int aesKeyDocId) async {
  //   final DMemoryDoc walletDoc = DMemoryDoc.fromBuffer(wallet);

  //   /// Create a document from response buffer.
  //   final DMemoryDoc responseDoc = DMemoryDoc.fromBuffer(responseBuffer);

  //   /// Create a doc from the device pin buffer.
  //   final DMemoryDoc devPinDoc = DMemoryDoc.fromBuffer(devicePin);

  //   /// Create pointers.
  //   final Pointer<Uint8> pinCodePtr = this.getPointer(pinCode);

  //   /// Get length from each pointer.
  //   final int pinCodeLen = pinCode.length;

  //   /// Update a wallet. As a result wa get a status (failure: 0, success: 1).
  //   final int status = _libProvider.setResponseUpdateWallet(
  //     walletDoc.docId,
  //     devPinDoc.docId,
  //     responseDoc.docId,
  //     pinCodePtr,
  //     pinCodeLen,
  //     aesKeyDocId,
  //   );

  //   if (status != 1)
  //     return OperationResult.onError(ErrorCode.set_wallet_update_request,
  //         debugMessage: 'Set response update wallet returned false');

  //   responseDoc.dispose();
  //   devPinDoc.dispose();
  //   walletDoc.dispose();

  //   return OperationResult.onSuccess<bool>(true);
  // }

  // bool comparePubKeys(List array1, List array2) {
  //   if (array1.length == array2.length) {
  //     bool result = array1.every((value) => array2.contains(value));
  //     return result;
  //   } else {
  //     return false;
  //   }
  // }

  // /// Returns a current balance of the wallet.
  // Future<Balance> getBalance(List<int> wallet) async {
  //   DMemoryDoc walletDoc = DMemoryDoc.fromBuffer(wallet);

  //   int balanceLocked = _libProvider.getWalletBalanceLocked(walletDoc.docId);
  //   int balanceAvailable = _libProvider.getWalletBalanceAvailable(walletDoc.docId);

  //   walletDoc.dispose();

  //   return Balance(balanceLocked, balanceAvailable);
  // }

  // bool addBills(int walletDocId, List<List<int>> billBuffers) {
  //   bool result = false;

  //   billBuffers.forEach((billBuffer) {
  //     DMemoryDoc billDoc = DMemoryDoc.fromBuffer(billBuffer);
  //     result = addBill(walletDocId, billDoc.docId);
  //   });

  //   return result;
  // }

  // /// Returns a current balance of the wallet.
  // bool removeBill(int walletDocId, List<int> pk) {
  //   final Pointer<Uint8>? pointer = calloc<Uint8>(pk.length);
  //   for (int i = 0; i < pk.length; ++i) {
  //     pointer![i] = pk[i];
  //   }
  //   bool result = _libProvider.removeBill(walletDocId, pointer, pk.length) == 1;

  //   return result;
  // }

  // bool addBill(int walletDocId, int billDocId) {
  //   final result = _libProvider.addBill(walletDocId, billDocId) == 1;

  //   return result;
  // }

  // Future<bool> changePin(
  //   List<int> walletBuffer,
  //   List<int> devPinBuffer,
  //   Uint8List pinCode,
  //   Uint8List newPinCode,
  //   int aesKeyId,
  //   int newAesKeyId,
  // ) async {
  //   DMemoryDoc walletDoc = DMemoryDoc.fromBuffer(walletBuffer);
  //   DMemoryDoc devPinDoc = DMemoryDoc.fromBuffer(devPinBuffer);

  //   // Create pointers.
  //   final Pointer<Uint8> pinCodePtr = this.getPointer(pinCode);
  //   final Pointer<Uint8> newPinCodePtr = this.getPointer(newPinCode);

  //   /// Get length from each pointer.
  //   final int pinCodeLen = pinCode.length;
  //   final int newPinCodeLen = newPinCode.length;

  //   /// Change pin code.
  //   int result = libProvider.changePin(
  //       walletDoc.docId, devPinDoc.docId, pinCodePtr, pinCodeLen, newPinCodePtr, newPinCodeLen, aesKeyId, newAesKeyId);

  //   devPinDoc.dispose();
  //   walletDoc.dispose();

  //   return result == 1;
  // }

  // /// Validates a pin-code. Returns true if valid.
  // bool validatePin(Uint8List pinCode, List<int> walletBuffer, List<int> devPinBuffer, int aesKeyId) {
  //   // Create pointers.
  //   final Pointer<Uint8> pinCodePtr = this.getPointer(pinCode);

  //   /// Get length from each pointer.
  //   final int pinCodeLen = pinCode.length;

  //   /// Create a wallet doc from the buffer.
  //   DMemoryDoc walletDoc = DMemoryDoc.fromBuffer(walletBuffer);
  //   DMemoryDoc devPinDoc = DMemoryDoc.fromBuffer(devPinBuffer);

  //   /// Validate.
  //   int result = libProvider.validatePin(walletDoc.docId, devPinDoc.docId, pinCodePtr, pinCodeLen, aesKeyId);

  //   devPinDoc.dispose();
  //   walletDoc.dispose();

  //   return result == 1;
  // }

  // /// Returns a randomly generated AES key id.
  // int generateAESKey(int prevId) {
  //   int newId = libProvider.generateAESKey(prevId);

  //   return newId;
  // }

  Pointer<Uint8> getPointer(List<int> source) {
    final Pointer<Uint8> pointer = calloc<Uint8>(source.length);

    for (int i = 0; i < source.length; ++i) {
      pointer[i] = source[i];
    }
    return pointer;
  }
}

/// A simple model fot pubKey and amount delivery.
class BillContainer {
  final List<int> pubKey;
  final int amount;

  BillContainer(this.pubKey, this.amount);
}

class ContractError implements Exception {
  final dynamic message;
  ContractError([this.message]);
}

class Balance {
  int locked;
  int available;

  Balance(this.locked, this.available);
}

class OperationResult<T> {
  ErrorCode _errorCode = ErrorCode.none;
  String? _debugMessage;
  T? _data;

  bool get isSuccess => _errorCode == ErrorCode.none;

  ErrorCode get errorCode => _errorCode;

  String? get debugMessage => _debugMessage;

  T? get data => _data;

  OperationResult._success(T data) {
    this._data = data;
  }

  OperationResult._error(ErrorCode errorCode, String? debugMessage, {T? data}) {
    this._errorCode = errorCode;
    this._debugMessage = debugMessage;
    this._data = data;
  }

  static OperationResult onSuccess<T>(T data) {
    return OperationResult<T>._success(data);
  }

  static OperationResult onError(ErrorCode errorCode,
      {String? debugMessage, dynamic data}) {
    return OperationResult._error(errorCode, debugMessage, data: data);
  }
}

enum ErrorCode {
  none,
  invoice_create_error,
  invoice_expired_error,
  contract_create_error,
  wallet_create_error,
  get_wallet_update_request,
  set_wallet_update_request,
  faucet_is_not_active,
  wallet_pub_keys_are_empty_error,
  update_wallet_error,
  update_transactions_error,
  update_payment_requests_error,
  card_create_empty_name_error,
  card_create_pin_length_error,
  card_create_confidence_lvl_error,
  card_create_error,
  card_update_error,
  card_delete_error,
  card_not_found,
  top_up_error,
  get_invoice_error,
  register_invoice_error,
  register_contract_error,
  send_contract_error,
  socket_result_error,
  api_response_empty_error,
  network_error,
  network_socket_error,
  network_timeout_error,
  network_other_error,
  invalid_amount_error,
  invalid_pin_code,
  item_not_found,
  pin_code_not_provided,
  derivers_empty,
  derivers_export_error,
  derivers_import_error,
  firebase_token_error,
  get_otp_error,
  otp_verify_error,
  files_upload_error,
  files_download_error,
  payout_error,
  register_event_error,
}
