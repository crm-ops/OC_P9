trigger UpdateAccountTurnover on Order (after update) {
	
    
        
    

        //the accountIds set stores the ids covered by the trigger
        Set<Id> acntIds = new Set<Id>();

        //List of final account updates to process in one go
        List<Account> acntsToUpdate = new List<Account>(); 

        

        



        //this account list is the final list to updt the DB  
       
        if (!Trigger.isDelete) {
            for (Order o : Trigger.new) {
                acntIds.add(o.AccountId);
            }
        }
    
        if (Trigger.isUpdate || Trigger.isDelete) {
            for (Order o : Trigger.old) {
                acntIds.add(o.AccountId);
            }
        }

        //List of sour account filtered by ids covered in the trigger
        List<Account> acntsSource = [SELECT Id, Chiffre_d_affaire__c FROM Account WHERE Id =:acntIds ];
        //Query that aggregates all order TotalAmt by account - migh not be useful
        // List<AggregateResult> ars = [SELECT AccountId, Sum(TotalAmount) Turnover FROM Order WHERE AccountId IN :acntIds GROUP BY AccountId];
    
        // get a map of the accounts with the aggregated revenue field
       //  Map<id, Account> popMap = new Map<id,Account>([select id, Chiffre_d_affaire__c from Account where id IN :accntIds]);
    
        
       
        /*for (AggregateResult ar : ars) {
            popMap.get(ar.Id).Chiffre_d_affaire__c= 2005.32;
            //popMap.get(ar.get('AccountId')).Sum_of_Positions__c = ar.get('expr0');
            accntsToUpdate.add(popMap.get(ar.id));
        }*/

        for(Order o : Trigger.new){
            
                for (Account acc : acntsSource) {

                try{
                acc.Chiffre_d_affaire__c = acc.Chiffre_d_affaire__c + o.TotalAmount;
                
                }catch (System.NullPointerException e) {
                acc.Chiffre_d_affaire__c = 0 + o.TotalAmount;
                }
                
                acntsToUpdate.add(acc);
            }
        }
    
        //final bulkified account update
        update acntsToUpdate;


}