trigger UpdateAccountTurnover on Order (after update) {
	

        //the accountIds set stores the ids covered by the trigger
        Set<Id> acntIds = new Set<Id>();

        //List of final account updates to process in one go
        List<Account> acntsToUpdate = new List<Account>(); 

        //this account list is the final list to updt the DB  
        if (Trigger.isUpdate) {
            for (Order o : Trigger.new) {

                acntIds.add(o.AccountId);
            }
        }

        
        List<Account> acntsSource = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id =:acntIds ];
        List<AggregateResult> acntsTarget = [SELECT AccountId, SUM(TotalAmount) ca from Order WHERE AccountId=: acntIds GROUP BY AccountId ]; 



        for (Account a : acntsSource) {

                for (AggregateResult ar :  acntsTarget) {
                    if(a.Id == ar.get('AccountId')) {

                        a.Chiffre_d_affaire__c = (Decimal)ar.get('ca');
                        acntsToUpdate.add(a);

                    }

                }

        }


        
        //final bulkified account update
        update acntsToUpdate;


}