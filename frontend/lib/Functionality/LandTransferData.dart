class LandTransferData {
  String transferorCNIC;
  String transfereeCNIC;
  String transferType;
  String landTehsil;
  String landKhasra;
  String landDivision;

  LandTransferData({
    required this.transferorCNIC,
    required this.transfereeCNIC,
    required this.transferType,
    required this.landTehsil,
    required this.landKhasra,
    required this.landDivision,
  });
  LandTransferData.initWithTransferorCNIC(String transferorCNIC)
      : this.transferorCNIC = transferorCNIC,
        transfereeCNIC = '',
        transferType = '',
        landTehsil = '',
        landKhasra = '',
        landDivision = '';

  void updateTransferorCNIC(String cnic) {
    transferorCNIC = cnic;
  }

  void updateDetails({
    String? transferor,
    String? transferee,
    String? type,
    String? tehsil,
    String? khasraNumber,
    String? division,
  }) {
    if (transferor != null) this.transferorCNIC = transferor;
    if (transferee != null) this.transfereeCNIC = transferee;
    if (type != null) this.transferType = type;
    if (tehsil != null) this.landTehsil = tehsil;
    if (khasraNumber != null) this.landKhasra = khasraNumber;
    if (division != null) this.landDivision = division;
  }

  void printDetails() {
    print("Transferor CNIC: $transferorCNIC");
    print("Transferee CNIC: $transfereeCNIC");
    print("Transfer Type: $transferType");
    print("Land Tehsil: $landTehsil");
    print("Land Khasra: $landKhasra");
    print("Land Division: $landDivision");
  }

  // Add similar methods for other fields as necessary

  // Method to clear all data
  void clear() {
    transferorCNIC = '';
    transfereeCNIC = '';
    transferType = '';
    landTehsil = '';
    landKhasra = '';
    landDivision = '';
  }

  // Optionally, add a method to save the data to a database
  // Note: This is just a placeholder. Implement database saving logic as per your project requirements.
  Future<void> saveToDatabase() async {
    // Implement database saving logic here
    print("Saving data to database...");
    // Example: Save the data to a local database or send it to a server
  }
}
