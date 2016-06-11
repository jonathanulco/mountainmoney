contract PotFactory {

    struct PotContract {
        string  name;
        address address;
    }
    mapping(address => PotContract[]) contractsByFounder;
    mapping(address => PotContract[]) contractsByMember;

    function createContract (string name, uint multiplier, uint waitingWeeks, uint maxLoan) {
        new Pot(

        )
    }

    function addContractMember (address who, string contractName, address contractAddress) {
        contractsByMember[who] = PotContract(
            contractName;
            contractAddress;
        );
    }

    // READ METHODS for "calls"

    function contractsForSet (PotContract[] set) internal returns (string){
        string response = '['
        for (uint j = 0; j < set.length; j++) {
            var contract = set[j]
            if(!contract){
                response += '{name: ' + j.name + ', address:' + string(j.address) + '},';
            }
        }
        response += ']';
        return response;
    }

    function contractsForFounder (address who) constant returns (string) {
        return contractsForSet(contractsByFounder[who]);
    }

    function contractsForMember (address who) constant returns (string) {
        return contractsForSet(contractsByMember[who]);
    }

}
