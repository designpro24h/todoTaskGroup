
  Stream<List<TaskModel>> getTasks({required String dateCreate}) {
    final String uid = FirebaseAuth.instance.currentUser!.uid.toString();

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .where('dateCreate', isEqualTo: dateCreate)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromJson(doc.data(), doc.id)).toList());
  }