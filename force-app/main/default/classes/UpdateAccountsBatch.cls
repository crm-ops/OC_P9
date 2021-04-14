global class UpdateAccountsBatch implements Database.Batchable<sObject>, Database.Stateful {
    
   global Database.QueryLocator start(Database.BatchableContext bc){ 
       //Requeter seulement les comptes qui ont au moins une commande avec le Status 'Ordered'
       return Database.getQueryLocator('SELECT Id, Chiffre_d_affaire__c FROM Account WHERE ImportStatus__c=\'AccountImported\'');

   }
    
   global void execute(Database.BatchableContext bc, List<Account> scope){      

       list<AggregateResult> listOrders =  [SELECT AccountId ,Sum(TotalAmount) sumTotalAmount  FROM Order WHERE ImportStatus__c='OrdersImported' GROUP BY AccountId];
       
		for(integer i=0; i < scope.size(); i++){
			Account myAccount = scope[i];
			myAccount.Chiffre_d_affaire__c = 0;
           for(integer j=0; j < listOrders.size(); j++){
               if(listOrders[j].get('AccountId') == myAccount.Id){
                   myAccount.Chiffre_d_affaire__c = (Decimal)listOrders[j].get('sumTotalAmount');
               }                   
           }
       }
       
       update scope;
   }    
    
   global void finish(Database.BatchableContext info){     
       
   } 
}