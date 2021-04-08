trigger UpdateAccountTurnover on Order (after insert, after update) {
	
    
        List<Account> acntsToUpdate = new List<Account>(); 
    

        //the accountIds set stores the ids covered by the trigger
        Set<Id> accntIds = new Set<Id>();

        //this account list is the final list to updt the DB  
        List<Account> accntsToUpdate = new List<Account>();
    
        if (!Trigger.isDelete) {
            for (Order o : Trigger.new) {
                accntIds.add(o.AccountId);
            }
        }
    
        if (Trigger.isUpdate || Trigger.isDelete) {
            for (Order o : Trigger.old) {
                accntIds.add(o.AccountId);
            }
        }
    
        // get a map of the accounts with the aggregated revenue field
        Map<id, Account> popMap = new Map<id,Account>([select id, Chiffre_d_affaire__c from Account where id IN :accntIds]);
    
        List<AggregateResult> ars = [SELECT AccountId, Sum(TotalAmount) FROM Order WHERE AccountId IN :accntIds GROUP BY AccountId];
        
        for (AggregateResult ar : ars) {
            popMap.get(ar.Id).Chiffre_d_affaire__c= 2005.32;
            //popMap.get(ar.get('AccountId')).Sum_of_Positions__c = ar.get('expr0');
            accntsToUpdate.add(popMap.get(ar.id));
        }
    
        update accntsToUpdate;


}