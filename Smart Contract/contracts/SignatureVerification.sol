// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SignatureVerification{

	function getMessageHash(address _licenseOwner,string memory _userEncryptedKycDetails) public pure returns(bytes32){
		return keccak256(abi.encodePacked(_licenseOwner,_userEncryptedKycDetails));
	}

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns(bytes32){
		return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",_messageHash));
	}

	function verifySignature(address _signer, address _licenseOwner,string memory _userEncryptedKycDetails, bytes memory _signature) public pure returns(bool){
		bytes32 messageHash = getMessageHash(_licenseOwner, _userEncryptedKycDetails);
		bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
		return recoverSigner(ethSignedMessageHash , _signature) == _signer;
	}

    function recoverSigner(bytes32 _ethSignedMessageHash , bytes memory _signature) public pure returns(address){
		(bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
		return ecrecover(_ethSignedMessageHash,v,r,s);
	}

	function splitSignature(bytes memory _sig) public pure returns(bytes32 r, bytes32 s, uint8 v){
		require(_sig.length == 65, "invalid signature length");
		assembly{
			r := mload(add(_sig,32))
			s := mload(add(_sig,64))
			v := byte(0, mload(add(_sig,96)))
		}
	}
}