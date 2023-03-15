import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';

class LibProvider {
  static final DynamicLibrary dyLib = dyLibOpen('tagionmobile'); // <-- place lib name here

  static final LibProvider _provider = LibProvider._internal();

  factory LibProvider() {
    return _provider;
  }

  LibProvider._internal();

  /// Function for opening dynamic library.
  static DynamicLibrary dyLibOpen(String name, {String path = './'}) {
    var fullPath = _platformPath(name, path: path);
    if (Platform.isIOS) {
      return DynamicLibrary.process();
    } else {
      return DynamicLibrary.open(fullPath);
    }
  }

  /// Function returning path to library object.
  static String _platformPath(String name, {String path = ''}) {
    if (Platform.isLinux) {
      return path + 'linux/' + 'lib' + name + '.so';
    }
    if (Platform.isAndroid) {
      return path + 'android/' + 'lib' + name + '.so';
    }
    if (Platform.isMacOS) {
      return path + 'lib' + name + '.a';
    }
    if (Platform.isIOS) {
      return path + 'lib' + name + '.a';
    }

    throw Exception('Platform is not implemented');
  }

  void startRuntime() {
    int status = rtInitNative();
    print('Lib runtime status: $status');
  }

  void stopRuntime() {
    int status = rtStopNative();
    print('Lib runtime status: $status');
  }

  /// Dart functions.
  final CreateDocType createDoc = dyLib.lookup<NativeFunction<CreateDocNative>>('create_doc').asFunction();

  ///
  final GetStrByKeyType getStrByTag =
      dyLib.lookup<NativeFunction<GetStrByKeyNative>>('doc_get_str_by_key').asFunction();

  ///
  final GetIntByKeyType getIntByTag =
      dyLib.lookup<NativeFunction<GetIntByKeyNative>>('doc_get_int_by_key').asFunction();

  ///
  final GetLongByKeyType getLongByTag =
      dyLib.lookup<NativeFunction<GetLongByKeyNative>>('doc_get_ulong_by_key').asFunction();

  ///
  final DeleteByIdType delDocById = dyLib.lookup<NativeFunction<DeleteByIdNative>>('delete_doc_by_id').asFunction();

  ///
  final GetDocLenByKeyType getDocLen =
      dyLib.lookup<NativeFunction<GetDocLenByKeyNative>>('doc_get_docLen_by_key').asFunction();

  ///
  final GetDocPtrByKeyType getDocPtr =
      dyLib.lookup<NativeFunction<GetDocPtrByKeyNative>>('doc_get_docPtr_by_key').asFunction();

  ///
  final WalletCreateType walletCreate = dyLib
      .lookup<NativeFunction<WalletCreateNative>>(
          '_D6tagion6mobile16WalletWrapperApi13wallet_createFxPhxkxkxPaxkxQfxkkZk')
      .asFunction();

  // ///
  // final WalletRestoreType walletRestore =
  //     dyLib.lookup<NativeFunction<WalletRestoreNative>>('wallet_restore').asFunction();

  // ///
  // final InvoiceCreateType invoiceCreate =
  //     dyLib.lookup<NativeFunction<InvoiceCreateNative>>('invoice_create').asFunction();

  // ///
  // final ContractCreateType contractCreate =
  //     dyLib.lookup<NativeFunction<ContractCreateNative>>('contract_create').asFunction();

  // /// Create contract with amount.
  // final ContractCreateWithAmountType contractCreateWithAmount =
  //     dyLib.lookup<NativeFunction<ContractCreateWithAmountNative>>('contract_create_with_amount').asFunction();

  // final ContractCreateWithPubKeyType contractCreateWithPubKey =
  //     dyLib.lookup<NativeFunction<ContractCreateWithPubKeyNative>>('contract_create_with_pubkey').asFunction();

  // final GetDeriversType getDerivers = dyLib.lookup<NativeFunction<GetDeriversNative>>('get_derivers').asFunction();

  // final SetDeriversType setDerivers = dyLib.lookup<NativeFunction<SetDeriversNative>>('set_derivers').asFunction();

  // final AddDeriversType addDerivers = dyLib.lookup<NativeFunction<AddDeriversNative>>('add_derivers').asFunction();

  /// Create contract with amount.
  // final GetPubKeyType getPubKey = dyLib.lookup<NativeFunction<GetPubKeyNative>>('get_pub_key').asFunction();

  ///
  final GetDocLenByIdType getDocLenById = dyLib.lookup<NativeFunction<GetDocLenByIdNative>>('get_docLen').asFunction();

  ///
  final GetDocPtrByIdType getDocPtrById = dyLib.lookup<NativeFunction<GetDocPtrByIdNative>>('get_docPtr').asFunction();

  // ///
  final DruntimeCallType rtInitNative =
      dyLib.lookup<NativeFunction<StatusCallNative>>('_D6tagion6mobile16WalletWrapperApi8start_rtFZl').asFunction();

  // ///
  final DruntimeCallType rtStopNative =
      dyLib.lookup<NativeFunction<StatusCallNative>>('_D6tagion6mobile16WalletWrapperApi7stop_rtFZl').asFunction();

  ///
  final GetMemberCountType getMembersCount =
      dyLib.lookup<NativeFunction<GetMemberCountNative>>('doc_get_memberCount').asFunction();

  ///
  final GetBufferPtrByKeyType getBufferPtr =
      dyLib.lookup<NativeFunction<GetBufferPtrByKeyNative>>('doc_get_bufferPtr_by_key').asFunction();

  ///
  final GetBufferLenByKeyType getBufferLen =
      dyLib.lookup<NativeFunction<GetBufferLenByKeyNative>>('doc_get_bufferLen_by_key').asFunction();

  // ///
  // final GetWalletBalanceLockedType getWalletBalanceLocked =
  //     dyLib.lookup<NativeFunction<GetWalletBalanceLockedNative>>('get_balance_locked').asFunction();

  // ///
  // final GetWalletBalanceAvailableType getWalletBalanceAvailable =
  //     dyLib.lookup<NativeFunction<GetWalletBalanceAvailableNative>>('get_balance_available').asFunction();

  // ///
  // final GetRequestUpdateWalletType getRequestUpdateWallet =
  //     dyLib.lookup<NativeFunction<GetRequestUpdateWalletNative>>('get_request_update_wallet').asFunction();

  // ///
  // final SetResponseUpdateWalletType setResponseUpdateWallet =
  //     dyLib.lookup<NativeFunction<SetResponseUpdateWalletNative>>('set_response_update_wallet').asFunction();

  // final AddBillType addBill = dyLib.lookup<NativeFunction<AddBillNative>>('add_bill').asFunction();

  // final RemoveBillType removeBill = dyLib.lookup<NativeFunction<RemoveBillNative>>('remove_bill').asFunction();

  // final GenerateAESKeyType generateAESKey =
  //     dyLib.lookup<NativeFunction<GenerateAESKeyNative>>('generateAESKey').asFunction();

  // ///
  // final ValidatePinType validatePin = dyLib.lookup<NativeFunction<ValidatePinNative>>('validate').asFunction();

  // ///
  // final ChangePinType changePin = dyLib.lookup<NativeFunction<ChangePinNative>>('change_pin').asFunction();
}

/// Type definitions.

/// D function declaration is: int64_t create_doc(const uint8_t* data_ptr, const uint64_t len)
typedef CreateDocNative = Uint64 Function(Pointer<Uint8>? dataPtr, Uint64 len);

/// D function declaration is: const(char*) doc_get_str_by_key(const uint64_t docId, const char* key_str, const uint64_t len)
typedef GetStrByKeyNative = Pointer<Utf8> Function(Uint64 docId, Pointer<Utf8> keyStr, Uint64);

/// D function declaration is: int32_t doc_get_int_by_key(const uint64_t docId, const char* key_str, const uint64_t len)
typedef GetIntByKeyNative = Int32 Function(Uint64 docId, Pointer<Utf8> keyStr, Uint64 len);
typedef GetIntByKeyType = int Function(int docId, Pointer<Utf8> keyStr, int len);

typedef GetLongByKeyNative = Int64 Function(Uint64 docId, Pointer<Utf8> keyStr, Uint64 len);

/// D function declaration is: void delete_doc_by_id(const uint64_t id)
typedef DeleteByIdNative = Void Function(Uint64 index);

typedef GetDocPtrByKeyNative = Pointer<Uint8> Function(Uint64 docId, Pointer<Utf8> keyStr, Uint64);
typedef GetDocLenByKeyNative = Uint64 Function(Uint64 docId, Pointer<Utf8> keyStr, Uint64);
typedef CreateDocType = int Function(Pointer<Uint8>? data, int len);
typedef GetStrByKeyType = Pointer<Utf8> Function(int docId, Pointer<Utf8> keyStr, int len);
typedef GetLongByKeyType = int Function(int docId, Pointer<Utf8> keyStr, int len);
typedef DeleteByIdType = void Function(int index);
typedef GetDocPtrByKeyType = Pointer<Uint8> Function(int docId, Pointer<Utf8> keyStr, int);
typedef GetDocLenByKeyType = int Function(int docId, Pointer<Utf8> keyStr, int);

/// Wallet functions
/// Create wallet.
typedef WalletCreateNative = Uint64 Function(Pointer<Uint8> pincodePtr, Uint32 pincodeLen, Uint32 aesDocId,
    Pointer<Utf8> questionsPtr, Uint32 questionsLen, Pointer<Utf8> answersPtr, Uint32 answersLen, Uint32 confidence);
typedef WalletCreateType = int Function(Pointer<Uint8> pincodePtr, int pincodeLen, int aesDocId,
    Pointer<Utf8> questionsPtr, int questionsLen, Pointer<Utf8> answersPtr, int answersLen, int confidence);

/// Restore wallet.
typedef WalletRestoreNative = Uint64 Function(Uint32 recoveryDocId, Pointer<Uint8> pincodePtr, Uint32 pincodeLen,
    Uint32 aesDocId, Pointer<Utf8> questionsPtr, Uint32 questionsLen, Pointer<Utf8> answersPtr, Uint32 answersLen);

typedef WalletRestoreType = int Function(int reciveryDocId, Pointer<Uint8> pincodePtr, int pincodeLen, int aesDocId,
    Pointer<Utf8> questionsPtr, int questionsLen, Pointer<Utf8> answersPtr, int answersLen);

/// Create invoice.
typedef InvoiceCreateNative = Uint32 Function(Uint32 walletDocId, Uint32 devPinId, Pointer<Uint8> pincodePtr,
    Uint32 pincodeLen, Uint32 aesDocId, Uint64 amount, Pointer<Utf8> labelPtr, Uint32 labelLen);
typedef InvoiceCreateType = int Function(int walletDocId, int devPinId, Pointer<Uint8> pincodePtr, int pincodeLen,
    int aesDocId, int amount, Pointer<Utf8> labelPtr, int labelLen);

/// Create contract.
typedef ContractCreateNative = Uint32 Function(Uint32 walletDocId, Uint32 devPinId, Uint32 invoiceDocId,
    Pointer<Uint8> pincodePtr, Uint32 pincodeLen, Uint32 aesDocId);
typedef ContractCreateType = int Function(
    int walletDocId, int devPinId, int invoiceDocId, Pointer<Uint8> pincodePtr, int pincodeLen, int aesDocId);

/// Create contract with amount.
typedef ContractCreateWithAmountNative = Uint32 Function(Uint32 walletDocId, Uint32 devPinId, Uint32 invoiceDocId,
    Pointer<Uint8> pincodePtr, Uint32 pincodeLen, Uint32 aesDocId, Uint64 amount);
typedef ContractCreateWithAmountType = int Function(int walletDocId, int devPinId, int invoiceDocId,
    Pointer<Uint8> pincodePtr, int pincodeLen, int aesDocId, int amount);

/// Create contract with pub key.
typedef ContractCreateWithPubKeyNative = Uint32 Function(Uint32 walletDocId, Uint32 devPinId, Pointer<Uint8> pubKeyPtr,
    Uint32 pubKeyLen, Pointer<Uint8> pincodePtr, Uint32 pincodeLen, Uint32 aesDocId, Uint64 amount);
typedef ContractCreateWithPubKeyType = int Function(int walletDocId, int devPinId, Pointer<Uint8> pubKeyPtr,
    int pubKeyLen, Pointer<Uint8> pincodePtr, int pincodeLen, int aesDocId, int amount);

/// Get derivers.
typedef GetDeriversNative = Uint32 Function(
    Uint32 walletDocId, Uint32 devPinId, Pointer<Uint8> pincodePtr, Uint32 pincodeLen, Uint32 aesDocId);
typedef GetDeriversType = int Function(
    int walletDocId, int devPinId, Pointer<Uint8> pincodePtr, int pincodeLen, int aesDocId);

/// Set derivers.
typedef SetDeriversNative = Uint32 Function(Uint32 walletDocId, Uint32 devPinId, Pointer<Uint8> pincodePtr,
    Uint32 pincodeLen, Uint32 aesDocId, Uint32 deriversDocId);
typedef SetDeriversType = int Function(
    int walletDocId, int devPinId, Pointer<Uint8> pincodePtr, int pincodeLen, int aesDocId, int deriversDocId);

/// Add derivers.
typedef AddDeriversNative = Uint32 Function(Uint32 walletDocId, Uint32 devPinId, Pointer<Uint8> pincodePtr,
    Uint32 pincodeLen, Pointer<Utf8> deriversPtr, Uint32 deriversLen, Uint32 aesDocId);

typedef AddDeriversType = int Function(int walletDocId, int devPinId, Pointer<Uint8> pincodePtr, int pincodeLen,
    Pointer<Utf8> deriversPtr, int deriversLen, int aesDocId);

// Get derivers.
typedef GetPubKeyNative = Uint32 Function(
    Uint32 walletDocId, Uint32 devPinId, Pointer<Uint8> pincodePtr, Uint32 pincodeLen, Uint32 aesDocId);
typedef GetPubKeyType = int Function(
    int walletDocId, int devPinId, Pointer<Uint8> pincodePtr, int pincodeLen, int aesDocId);

typedef GetLockForAmountNative = Uint32 Function(Uint32 walletDocId, Uint64 amount);
typedef GetLockForAmountType = int Function(int walletDocId, int amount);

/// Get doc length.
typedef GetDocLenByIdNative = Uint64 Function(Uint32 docId);
typedef GetDocLenByIdType = int Function(int docId);

/// Get doc pointer.
typedef GetDocPtrByIdNative = Pointer<Uint8> Function(Uint32 docId);
typedef GetDocPtrByIdType = Pointer<Uint8> Function(int docId);

/// Member count.
typedef GetMemberCountNative = Uint64 Function(Uint64 docId);
typedef GetMemberCountType = int Function(int docId);

/// Get buffer pointer.
typedef GetBufferPtrByKeyNative = Pointer<Uint8> Function(Uint64 docId, Pointer<Utf8> keyStr, Uint64);
typedef GetBufferPtrByKeyType = Pointer<Uint8> Function(int docId, Pointer<Utf8> keyStr, int);

/// Get buffer length.
typedef GetBufferLenByKeyType = int Function(int docId, Pointer<Utf8> keyStr, int);
typedef GetBufferLenByKeyNative = Uint64 Function(Uint64 docId, Pointer<Utf8> keyStr, Uint64);

/// Get wallet balance locked.
typedef GetWalletBalanceLockedNative = Uint64 Function(Uint32 walletDocId);
typedef GetWalletBalanceLockedType = int Function(int walletDocId);

/// Get wallet balance available.
typedef GetWalletBalanceAvailableNative = Uint64 Function(Uint32 walletDocId);
typedef GetWalletBalanceAvailableType = int Function(int walletDocId);

/// Get request update wallet.
typedef GetRequestUpdateWalletNative = Uint32 Function(Uint32 walletDocId);
typedef GetRequestUpdateWalletType = int Function(int walletDocId);

/// Set response update wallet.
typedef SetResponseUpdateWalletNative = Uint32 Function(
  Uint32 walletDocId,
  Uint32 devPinId,
  Uint32 responseDocId,
  Pointer<Uint8> pincodePtr,
  Uint32 pincodeLen,
  Uint32 aesDocId,
);
typedef SetResponseUpdateWalletType = int Function(
  int walletDocId,
  int devPinId,
  int responseDocId,
  Pointer<Uint8> pincodePtr,
  int pincodeLen,
  int aesDocId,
);

/// Dart types definitions for calling the C's foreign functions.
typedef DruntimeCallType = int Function();

/// Calling the function that returned d-runtime status.
typedef StatusCallNative = Int64 Function();

/// Add new bill to bills
typedef AddBillNative = Uint32 Function(Uint32 walletDocId, Uint32 billDocId);
typedef AddBillType = int Function(int walletDocId, int billDocId);

/// Remove bill from bills
typedef RemoveBillNative = Uint32 Function(Uint32 walletDocId, Pointer<Uint8>? dataPtr, Uint64 len);
typedef RemoveBillType = int Function(int walletDocId, Pointer<Uint8>? data, int len);

/// Generates an aes key.
typedef GenerateAESKeyNative = Uint32 Function(Uint32 aesKeyDocId);
typedef GenerateAESKeyType = int Function(int aesKeyDocId);

/// Validate pin-code.
typedef ValidatePinNative = Uint32 Function(
    Uint32 walletDocId, Uint32 devPinId, Pointer<Uint8> pincodePtr, Uint32 pincodeLen, Uint32 aesKeyId);
typedef ValidatePinType = int Function(
    int walletDocId, int devPinId, Pointer<Uint8> pincodePtr, int pincodeLen, int aesKeyId);

/// Change pin code.
typedef ChangePinNative = Uint32 Function(Uint32 walletDocId, Uint32 devPinId, Pointer<Uint8> pincodePtr,
    Uint32 pincodeLen, Pointer<Uint8> newPincodePtr, Uint32 newPincodeLen, Uint32 aesKeyId, Uint32 newAesKeyId);
typedef ChangePinType = int Function(int walletDocId, int devPinId, Pointer<Uint8> pincodePtr, int pincodeLen,
    Pointer<Uint8> newPincodePtr, int newPincodeLen, int aesKeyId, int newAesKeyId);
