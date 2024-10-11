// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MedicalRecords {

    struct Record {
        string recordHash;
        string description;
        address doctor;
        uint256 timestamp;
    }

    struct Patient {
        address patientAddress;
        bool registered;
        mapping(uint256 => Record) records;
        uint256 recordCount;
        mapping(address => bool) authorizedDoctors;
    }

    mapping(address => Patient) public patients;
    address public admin;

    modifier onlyPatient() {
        require(patients[msg.sender].registered, "Not a registered patient");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not an admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerPatient(address _patientAddress) public onlyAdmin {
        require(!patients[_patientAddress].registered, "Already registered");
        patients[_patientAddress].registered = true;
        patients[_patientAddress].patientAddress = _patientAddress;
    }

    function addRecord(string memory _recordHash, string memory _description, address _doctor) public onlyPatient {
        uint256 recordId = patients[msg.sender].recordCount;
        patients[msg.sender].records[recordId] = Record({
            recordHash: _recordHash,
            description: _description,
            doctor: _doctor,
            timestamp: block.timestamp
        });
        patients[msg.sender].recordCount++;
    }

    function authorizeDoctor(address _doctor) public onlyPatient {
        patients[msg.sender].authorizedDoctors[_doctor] = true;
    }

    function revokeDoctorAccess(address _doctor) public onlyPatient {
        patients[msg.sender].authorizedDoctors[_doctor] = false;
    }

    function viewRecord(address _patientAddress, uint256 _recordId) public view returns (string memory, string memory, uint256) {
        require(patients[_patientAddress].authorizedDoctors[msg.sender], "Not authorized");
        Record storage record = patients[_patientAddress].records[_recordId];
        return (record.recordHash, record.description, record.timestamp);
    }
}
