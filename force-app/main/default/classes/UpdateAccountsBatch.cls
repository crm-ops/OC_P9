global class UpdateAccountsBatch implements Database.Batchable<sObject>{
    
   global Database.QueryLocator start(Database.BatchableContext bc){ 
       //Requeter seulement les comptes qui ont au moins une commande avec le Status 'Ordered'
       return Database.getQueryLocator('SELECT Id, Chiffre_d_affaire__c FROM Account WHERE ImportStatus__c=\'AccountImported\'');

   }
    
   global void execute(Database.BatchableContext bc, List<Account> scope){      

       list<Aggregate> listOrders =  [SELECT Id, TotalAmount, AccountId FROM Order];
       
		for(integer i=0; i < scope.size(); i++){
			Account myAccount = scope[i];
			myAccount.Chiffre_d_affaire__c = 0;
           for(integer j=0; j < listOrders.size(); j++){
               if(listOrders[j].AccountId == myAccount.Id){
                   myAccount.Chiffre_d_affaire__c = myAccount.Chiffre_d_affaire__c + listOrders[j].TotalAmount;
               }                   
           }
       }
       
       update scope;
   }    
    
   global void finish(Database.BatchableContext info){     
       
   } 
}