import 'package:get/get.dart';
import 'package:watts_clone/consts/auth_const.dart';

class ProfileService extends GetxController {
   static getProfileData(String id)  {
    return firebaseFirestore.collection(collectionUser).where('id',isEqualTo: id).get();
  }
}