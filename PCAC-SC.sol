pragma solidity ^0.4.23;

contract Patientcentricaccesscontrol  {
address public patient;
string public imagedescription; 
string patientimagehash;
string Patientpubkey;                                                  

//mappings
mapping (address=> bool) public recordList;//addresses of requestor and results (true or false)
mapping (address => bool) public approvedIRs; // result for approved address of IR (true or false)
mapping(address=>string) public imageHashes; // used to map requester address with imagehash
  
//constructor
function Patientcentricaccesscontrol() {
    imagedescription = "Liver Ultrasound Image - B-Mode";
    patient= msg.sender;
    Patientpubkey= "tk2348jbjkasAdorfsertakAFoipsfasfSE"; //example public key can be added
    patientimagehash= "QmNaS5gQzoPxr3S2n6T6BsFuVRmMFwpohLVFfAFrU8gyTq";
}
    //modifiers
     modifier  Onlypatient(){
        require(msg.sender == patient); 
        _;
    }
    modifier Notpatient(){
        require(msg.sender!=patient);
        _;
    }
    
 //events
    event ContractCreated(address owner, string info);
    event RequestedForApproval(address requester, string info);    
    event Requestaccepted(address patient , string info);
    event UserRemoved(address requesterAddress, string info);
    event Approved(address requester, string info);     
    event Requestdenied(address patient, string info);
    event Reason(address requester, string info);
    event AuthorizationSuccess(address requester,string info, address patient);
    event AuthorizationFailed(address requester,string info, address patient);
    
//functions
    function Create_contract()Onlypatient{
       ContractCreated(msg.sender, "Requests can be accepted based on contract patient, Notes: Contract patient"); //Defining contract by patient 1 for example
  }
    
  function Request_access(address patientAddress, string notes, string IRpublickey) Notpatient  {
  RequestedForApproval(msg.sender, "Agreed with contract. Usage:Purpose");
    }
    
 
function Approve_IRs( address requesterAddress, string imageHash) Onlypatient public {
  imageHashes[requesterAddress] = imageHash; //update the mapping 
  if(keccak256(imageHashes[requesterAddress]) == keccak256(patientimagehash)) //compare hashes to validate authorization
  {
      Requestaccepted(msg.sender, "approved by patient. ");
      recordList[requesterAddress] = true;
      approvedIRs[requesterAddress] = true;
      Approved(requesterAddress, "Authorized to access image");
  }
  else if(keccak256(imageHashes[requesterAddress]) != keccak256(patientimagehash))
  {
      Requestdenied (msg.sender, "Failed to be approved by patient");
      recordList[requesterAddress] = false;
      approvedIRs[requesterAddress] = false;
      Reason(requesterAddress, " Need more detailed information to access my image");
  }
}

function Remove_IRs(address requesterAddress, string imageHash) public {
    require(msg.sender == patient); 
    imageHashes[requesterAddress] = imageHash;
     if(keccak256(imageHashes[requesterAddress]) == keccak256(patientimagehash))
      {
      UserRemoved(msg.sender, "removed");
      recordList[requesterAddress] = false;
      approvedIRs[requesterAddress] = false;
      Reason(requesterAddress, " Contract expired");
      }
}
function Trace_authorization( address requesterAddress, address patientAddress ) public {
 if(recordList[requesterAddress] == true && approvedIRs[requesterAddress] == true )
    if(patientAddress == patient) {
        //event showing image access is verified by the patient 
        AuthorizationSuccess(requesterAddress,"Authorized to access image by:", patientAddress);
    }
   else  if(recordList[requesterAddress] == false && approvedIRs[requesterAddress] == false )
   if(patientAddress == patient) {
            AuthorizationFailed(requesterAddress,"Liver image is not authorized to access by:", patientAddress);
        }
      }
}
