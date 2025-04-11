class PatientsModel {
  String name;
  String iconPath;
  String gender;
  String duration;
  String hospital;
  bool viewIsSelected;

  PatientsModel({
    required this.name,
    required this.iconPath,
    required this.gender,
    required this.duration,
    required this.hospital,
    required this.viewIsSelected,
  });

  static List < PatientsModel > getPatientInfo() {
    List < PatientsModel > patient = [];

    patient.add(
      PatientsModel(
        name: 'Evra Eliya', 
        iconPath: 'assets/icons/male-clerk-at-a-convenience-store-upper-body-svgrepo-com.svg', 
        gender: 'male', 
        duration: '10 days', 
        hospital: 'Mt Kenya', 
        viewIsSelected: true
      )
    );

     patient.add(
      PatientsModel(
        name: 'Susan Strong', 
        iconPath: 'assets/icons/female-lawyer-upper-body-svgrepo-com.svg', 
        gender: 'female', 
        duration: '1 days', 
        hospital: 'Gesusu', 
        viewIsSelected: false
      )
    );

    return patient;
  }

}