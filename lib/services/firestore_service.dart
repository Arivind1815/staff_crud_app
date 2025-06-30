import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff.dart';

class FirestoreService {
  final CollectionReference staffCollection =
      FirebaseFirestore.instance.collection('staff');

  Future<void> addStaff(Staff staff) async {
    await staffCollection.add(staff.toMap());
  }

  Future<void> updateStaff(Staff staff) async {
    if (staff.docId != null) {
      await staffCollection.doc(staff.docId).update(staff.toMap());
    }
  }

  Future<void> deleteStaff(String docId) async {
    await staffCollection.doc(docId).delete();
  }

  Future<void> clearAllStaff() async {
    final snapshot = await staffCollection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<bool> isDuplicateId(String id) async {
    final result = await staffCollection.where('id', isEqualTo: id).get();
    return result.docs.isNotEmpty;
  }

  Stream<List<Staff>> getStaffList({String sortBy = 'name'}) {
    return staffCollection.orderBy(sortBy).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Staff.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
