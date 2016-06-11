contract Pot {

    uint public multiplier;
    uint public waitingWeeks;
    uint public timeToPayBack;
    uint public maxLoan;
    uint public rateOfBorrowing;
    // uint public rateOfUnanimityForNewMembers;

    address public founder;
    address[] members;
    address[] invited;
    mapping(address => int) accountBalance; //signed

    struct Transaction {
        uint    timestamp;
        int     amountIntoPot;
    }

    mapping(address => Transaction[]) accountHistory;

    // TRANSACTIONS: State-altering methods

    function invite(address newMember){
      if(msg.sender == founder){
        invited.push(newMember);
      }
    }

    function join(){
      var hasInvite = false;
      for (uint i = 0; i < invited.length; i++) {
        if(invited[i] == msg.sender){
          hasInvite = true;
          break;
        }
      }
      if(!hasInvite){
        return;
      }

      bool isAlreadyMember = false;
      for (uint l = 0; l < members.length; l++) {
        if(members[l] == msg.sender){
          isAlreadyMember = true;
          break;
        }
      }
      if(isAlreadyMember){
        return;
      }
      if(accountBalance[msg.sender] > 0){
        // Already has account!
        return;
      }

      // Everything's ok, let's add the member
      accountBalance[msg.sender] = 0;
      members.push(msg.sender);

    }

    function deposit(){

        bool isMember = false;
        for (uint i = 0; i < members.length; i++) {
          if(members[i] == msg.sender){
            isMember = true;
            break;
          }
        }
        if(!isMember){
          return;
        }

        if(msg.value == 0){
          return;
        }

        accountHistory[msg.sender].push(Transaction(
          now,
          int(msg.value)
        ));

        accountBalance[msg.sender] = accountBalance[msg.sender] + int(msg.value);

    }

    function withdraw(uint amount){

        bool isMember = false;
        for (uint i = 0; i < members.length; i++) {
          if(members[i] == msg.sender){
            isMember = true;
            break;
          }
        }
        if(!isMember){
          return;
        }

        if(amount == 0) return;

        if(accountBalance[msg.sender] <= 0 || accountBalance[msg.sender] < int(amount)){
          return;
        }

        if(this.balance < amount){
          return;
        }

        msg.sender.send(amount);

        accountHistory[msg.sender].push(Transaction(
          now,
          -int(amount)
        ));

        accountBalance[msg.sender] = accountBalance[msg.sender] - int(amount);

    }

    function loan(uint amount){

        bool isMember = false;
        for (uint i = 0; i < members.length; i++) {
          if(members[i] == msg.sender){
            isMember = true;
            break;
          }
        }
        if(!isMember){
          return;
        }

        if(amount == 0) return;

        if(this.balance < amount){
          return;
        }

        var borrowBase = int(0);
        for (uint j = 0; j < accountHistory[msg.sender].length; j++) {
          if(accountHistory[msg.sender][j].amountIntoPot >= 0){
            if (now < accountHistory[msg.sender][j].timestamp + waitingWeeks * 1 weeks){
              continue;
            }
          }
          borrowBase += accountHistory[msg.sender][j].amountIntoPot;
        }

        var amountCanBorrow = borrowBase * int(multiplier);
        if(amountCanBorrow > int(this.balance)){
            return;
        }

        if(int(amount) > amountCanBorrow){
            return;
        }

        msg.sender.send(amount);

        accountHistory[msg.sender].push(Transaction(
          now,
          -int(amount)
        ));

        accountBalance[msg.sender] = accountBalance[msg.sender] - int(amount);

    }

    // CALLS: Read only operations

    function canWithdraw() returns (int){

      bool isMember = false;
      for (uint i = 0; i < members.length; i++) {
        if(members[i] == msg.sender){
          isMember = true;
          break;
        }
      }
      if(!isMember){
        return 0;
      }

      if(accountBalance[msg.sender] <= 0){
        return 0;
      }
      return accountBalance[msg.sender];

    }

    function canBorrow() returns (uint){

      bool isMember = false;
      for (uint i = 0; i < members.length; i++) {
        if(members[i] == msg.sender){
          isMember = true;
          break;
        }
      }
      if(!isMember){
        return 0;
      }

      var borrowBase = int(0);
      for (uint k = 0; k < accountHistory[msg.sender].length; k++) {
        if(accountHistory[msg.sender][k].amountIntoPot >= 0){
            if (now < accountHistory[msg.sender][k].timestamp + waitingWeeks * 1 weeks){
                continue;
            }
        }
        borrowBase += accountHistory[msg.sender][k].amountIntoPot;
      }

      if(borrowBase < 0){
        return 0;
      }

      var amountCanBorrow = uint(borrowBase) * multiplier;
      if(amountCanBorrow > this.balance){
        amountCanBorrow = this.balance;
      }

      return amountCanBorrow;

    }

    function numberOfMembers() returns (uint){

      return members.length;

    }


    // function myAccountHistory() constant returns (Transaction[]){

    //   return accountHistory[msg.sender];

    // }

}
