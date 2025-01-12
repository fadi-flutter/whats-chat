import 'dart:developer';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:watts_clone/consts/auth_const.dart';
import 'package:watts_clone/controller/home_controller.dart';

class ProfileController extends GetxController {
  TextEditingController nameC = TextEditingController();
  TextEditingController aboutC = TextEditingController();
  TextEditingController phonenumberC = TextEditingController();
  RxBool isLoading = false.obs;
  var imgSrc = ''.obs;
  var imageData = '';
  var updateProfileProgress = false.obs;

  //updateProfile
  updateProfile(context) async {
    try {
      var data = firebaseFirestore.collection(collectionUser).doc(user!.uid);
      await data.update(
        {
          'username': nameC.text,
          'about': aboutC.text,
          'img_url': imgSrc.value.isEmpty
              ? HomeController.instance.imgurl.value
              : imageData,
        },
      );
      VxToast.show(context, msg: 'Profile updated successfully');
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  pickImage(context, source) async {
    //requesting permissions for accessing

    await Permission.photos.request();
    await Permission.camera.request();

    var status = await Permission.photos.status;

    if (!status.isGranted) {
      try {
        final img =
            //pick img from gallery or camera
            await ImagePicker().pickImage(source: source, imageQuality: 80);
        //store image path to a observable var imgSrc
        imgSrc.value = img!.path;
        VxToast.show(context, msg: 'Image picked');
      } on FileSystemException catch (e) {
        VxToast.show(context, msg: e.toString());
      }
    } else {
      VxToast.show(
        context,
        msg: 'Permission not given',
      );
    }
  }

  storeImage() async {
    updateProfileProgress(true);
    //converting the source of image to different form
    var name = path.basename(imgSrc.value);
    //setting destination where we want to store our data in firebase storage
    var destination = "images/${user!.uid}/$name";
    //creating storage
    Reference ref = FirebaseStorage.instance.ref().child(destination);
    //putting data into storage
    await ref.putFile(File(imgSrc.value));
    //getting the url uploaded to store in database
    var d = await ref.getDownloadURL();
    imageData = d;
    log(d);
    updateProfileProgress(false);
  }

  @override
  void onInit() {
    super.onInit();
    nameC.text = HomeController.instance.username.value;
    aboutC.text = HomeController.instance.about.value;
    phonenumberC.text = HomeController.instance.phone.value;
  }
}
