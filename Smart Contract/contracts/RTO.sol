// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Ownable.sol";
import "./SignatureVerification.sol";
contract RTO is Ownable, SignatureVerification{

    struct license{
        string userEncryptedKycDetails;
        uint licenseStartDate;
        bool isActivate;
    }

    mapping(address => license) public licenseDetails;
    mapping(string => string) public vehicleDetails;
    mapping(address => string) public ownerToVehicleMapping;
    mapping(bytes => bool) public usedSignature;

    event licenseCreated(address indexed _licenseOwner, uint indexed _licenseStartDate, string _userEncryptedKycDetails);

    function addLicense(string memory _userEncryptedKycDetails, bytes memory _signature) public{
        bool status = verifySignature(owner(),msg.sender, _userEncryptedKycDetails, _signature);
        require(status,"signature doesnot match");
        license memory lic = licenseDetails[msg.sender];
        require(!lic.isActivate,"user already have a valid license");
        lic.userEncryptedKycDetails = _userEncryptedKycDetails;
        lic.licenseStartDate = block.timestamp;
        licenseDetails[msg.sender] = lic;
        usedSignature[_signature] = true;
        emit licenseCreated(msg.sender,block.timestamp,_userEncryptedKycDetails);
    }

    function suspendLicense(address _licenseOwner) public onlyOwner{
        license memory lic = licenseDetails[_licenseOwner];
        require(lic.isActivate,"user doesn't have a valid license");
        lic.isActivate = false;
        licenseDetails[_licenseOwner] = lic;
    }

    function resumeLicense(address _licenseOwner) public onlyOwner{
        license memory lic = licenseDetails[msg.sender];
        require(!lic.isActivate,"user already have a valid license");
        lic.isActivate = true;
        licenseDetails[_licenseOwner] = lic;    
    }

    function renewLicense() public{
        license memory lic = licenseDetails[msg.sender];
        require(lic.isActivate,"user doesn't have a valid license");
        require(lic.licenseStartDate + (11 * 30 days) < block.timestamp, "Renew date not started yet");
        lic.licenseStartDate = block.timestamp;
        licenseDetails[msg.sender] = lic; 
    }

    function closeLicense(address _licenseOwner) public{
        license memory lic = licenseDetails[_licenseOwner];
        require(lic.isActivate,"user doesn't have a valid license");
        require(msg.sender == _licenseOwner || msg.sender == owner(),"Caller is not permitted to close the license of the request license card");
        delete licenseDetails[_licenseOwner]; 
    }

    function addVehicleDetails(string memory _vehicleNo, string memory _detailCid) public onlyOwner{
        vehicleDetails[_vehicleNo] = _detailCid;
    }

    function addVehicleOwner(address _vehicleOwner, string memory _vehicleNo) public onlyOwner{
        license memory lic = licenseDetails[msg.sender];
        require(lic.isActivate,"user doesn't have a valid license");
        ownerToVehicleMapping[_vehicleOwner] = _vehicleNo;
    }
}