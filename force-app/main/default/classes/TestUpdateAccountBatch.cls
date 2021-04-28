@isTest
private class TestUpdateAccountBatch {
    @isTest(SeeAllData=True)
    static void should_populate_account_chiffreAffaire() {

        //Create Pricebook
        Pricebook2 pb = new Pricebook2 (Name = 'Test PB001', Description ='Test PB001 Desc', IsActive=true); 
        Insert pb;

        Product2 pd1 = new Product2(Name = 'Chemise Verte longue XYX', Family = 'Chemise');
        Insert pd1;

         //Standard pricebook entry 
         Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard=true];
         System.debug('Value of standardPB>'+ standardPB.Id);

        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = pd1.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;

       

        //Create the PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = pd1.Id,
            UnitPrice = 1020,
            UseStandardPrice = false, 
            IsActive = true
        );
        Insert pbe;

        //Update previously imported account
        List<Account> pastImportAccounts = new List<Account>(); 
        for (Account a : [SELECT Id, ImportStatus__c FROM Account WHERE ImportStatus__c = 'AccountImported']) {
            a.ImportStatus__c = 'PreviouslyImported';
            pastImportAccounts.add(a);
        }
        update pastImportAccounts;

        //set up 1000 accounts
        List<Account> lai = new List<Account>();
        for (Integer i = 0; i<1;i++){
            Account a = new Account(Name = 'Test Account_'+i, Chiffre_d_affaire__c=0, ImportStatus__c='AccountImported');
            lai.add(a);
        }
        insert lai;


        //for each account create 1 contract 
        List<Contract> lci = new List<Contract>();
        List<Id> listAccountIds = new List<Id>();
        for (Account a : lai) {

            listAccountIds.add(a.Id);
            Contract c = new Contract(
            AccountId=a.Id,
            Status='Draft',
            StartDate = Date.newInstance(2021, 4, 1),
            ContractTerm = 24
            );

            lci.add(c);
        } 
            insert lci;

        Map<Id, Contract> mc= new Map<Id,Contract>([Select Id, AccountId from Contract WHERE AccountId in :listAccountIds]);  

        //for each account create 2 Orders per account 
       
        List<Order> loi = new List<Order>(); 
        for (Account a : lai) {
            for (Integer nborders = 0; nborders <2; nborders++){
                String crtId='';
                for(ID idKey:mc.keySet()) {
                    Contract c= mc.get(idKey);
                    if(c.AccountId==a.Id){
                        crtId=idKey;
                    }

                }
            
            

             Order o = new Order( AccountId = a.Id, EffectiveDate=Date.newInstance(2021, 4, 1) , ContractId = crtId , Status='Ordered', Pricebook2Id=pb.Id, ShipmentCost__c=350, ImportStatus__c='OrderImported');
             
             loi.add(o);
            }
        } 
            
            insert loi;

        
        List<Order> lou = [SELECT Id FROM Order WHERE Status ='Ordered' AND  ImportStatus__c='OrderImported' AND AccountId IN :listAccountIds];
        List<OrderItem> listoibase = new List<OrderItem>();
        for (Order o :lou) {

            OrderItem oi = new OrderItem(OrderId = o.Id, PricebookEntryId = pbe.Id, Quantity=10, UnitPrice = 150, ImportStatus__c='OrderItemImported');
            listoibase.add(oi);

        }

        insert listoibase;
        update lou;

        
       
   
        Test.startTest();
        UpdateAccountsBatch uab = new UpdateAccountsBatch();
        Id batchId = Database.executeBatch(uab);
        Test.stopTest();
        // after the testing stops, assert records were updated properly

        Account testAccount  = [select Id, Chiffre_d_affaire__c from Account where ImportStatus__c = 'AccountImported' AND Id IN :listAccountIds limit 1 ];
        List<AggregateResult> sumorders = [select sum(TotalAmount) sumorders from Order WHERE AccountId IN :listAccountIds];
        System.assertEquals(400, [select count() from Order WHERE AccountId IN :listAccountIds]);
        System.assertEquals(600000, sumorders[0].get('sumorders'));
        System.assertEquals(400, [select count() from OrderItem]);
        System.assertEquals(200, [select count() from Account where ImportStatus__c = 'AccountImported' AND Id IN :listAccountIds]);
        System.assertEquals(3000,  testAccount.Chiffre_d_affaire__c );
    
    }
}