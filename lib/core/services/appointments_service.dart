import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentsService {
  static Stream<QuerySnapshot> getAppointmentsStream(String uid) {
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('patientID', isEqualTo: uid)
        .orderBy('date', descending: false)
        .snapshots();
  }
}
