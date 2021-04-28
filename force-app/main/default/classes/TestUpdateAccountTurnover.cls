@isTest
private class TestUpdateAccountTurnover {
    @isTest(SeeAllData=True)
    static void should_aggregate_two_ordered_orders_on_account() {
        Account acc1 = new Account(Name = 'Test Account 1', Chiffre_d_affaire__c=0);
        insert acc1;

        Account acc2 = new Account(Name = 'Test Account 2', Chiffre_d_affaire__c=0);
        insert acc2;

        List<Account> al = new List<Account>();
            al.add(acc1);
            al.add(acc2);

        Product2 pd1 = new Product2(Name = 'Chemise Verte longue XYX', Family = 'Chemise');
        Insert pd1;

        
        //Create Pricebook
        Pricebook2 pb = new Pricebook2 (Name = 'Test PB002', Description ='Test PB002 Desc', IsActive=true); 
        Insert pb;

        List<Pricebook2> pblist = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Test PB002'];

    
        //Standard pricebook entry 
        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard=true];
        System.debug('Value of standardPB>'+ standardPB.Id);

        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = pd1.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
 

         //Create the PricebookEntry
         PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pblist[0].Id,
            Product2Id = pd1.Id,
            UnitPrice = 1020,
            UseStandardPrice = false, 
            IsActive = true
        );
        Insert pbe;

        List<PricebookEntry> pbelist = [SELECT Id, Pricebook2Id, Product2Id, UnitPrice, IsActive  FROM PricebookEntry];

        
        //Create the Contract
        Contract ctrct = new Contract(
            AccountId = acc1.Id,
            Status='Draft',
            StartDate = Date.newInstance(2021, 4, 1),
            ContractTerm = 24
        );

        Insert ctrct;

        //Create the Contract
        Contract ctrct2 = new Contract(
            AccountId = acc2.Id,
            Status='Draft',
            StartDate = Date.newInstance(2021, 4, 1),
            ContractTerm = 24
        );

        Insert ctrct2;

        //prepare to insert a list of 100 orders
        List<Order> listobase = new List<Order>();
        String crtid='';

        for(Account a:al) {
            if(a.id == acc1.Id){
                crtid=ctrct.Id;

            } else 
            {
                crtid=ctrct2.Id;
            }

            for (Integer i = 0; i<10;i++ ) {

                Order o = new Order(AccountId = a.Id, EffectiveDate=Date.newInstance(2021, 4, 1) , ContractId = crtid, Status='Ordered', Pricebook2Id=pblist[0].Id, ShipmentCost__c=350);
                listobase.add(o);
            }

        }

        insert listobase;

        List<Id> accntIds = new List<Id>();
        accntIds.add(acc1.Id);
        accntIds.add(acc2.Id);

        listobase = [SELECT Id,  AccountId, Pricebook2Id FROM Order WHERE Pricebook2Id= :pblist[0].Id AND AccountId IN :accntIds];
        
        //for each order create 1 orderitem line
        Integer qty = 0;
        List<OrderItem> listoibase = new List<OrderItem>();

        List<PricebookEntry> pbeid = [Select Id,  Pricebook2Id from PricebookEntry where PriceBook2Id = :pblist[0].Id];

        for ( Order o :listobase) {
            if (o.AccountId==acc1.Id && o.Pricebook2Id == pblist[0].Id) {
                qty=10;
            } else if (o.Pricebook2Id == pblist[0].Id) {
                qty = 20;
            }

           


            OrderItem oi = new OrderItem(OrderId = o.Id, PricebookEntryId = pbeid[0].Id, Quantity=qty, UnitPrice = 150);
            listoibase.add(oi);
        }


        //dml to insert line items & update orders in bulk 
        insert listoibase;
       



        Test.startTest();
        
       

        update listobase;
        
        
        
        Test.stopTest();

        Account accnt1TotalAmt = [SELECT Id,Chiffre_d_affaire__c FROM Account where Id =:acc1.Id];
        Account accnt2TotalAmt = [SELECT Id,Chiffre_d_affaire__c FROM Account where Id =:acc2.Id];
        
        List<Order> agr = [SELECT Id  FROM Order WHERE AccountId IN :accntIds];
        

        System.assertEquals(20, agr.size());
        System.assertEquals(15000,accnt1TotalAmt.Chiffre_d_affaire__c);
        System.assertEquals(30000,accnt2TotalAmt.Chiffre_d_affaire__c);


    }

    
    
    @isTest(SeeAllData=True)
    static void should_not_aggregate_two_orders_status_diff_from_ordered() {
        Account acc1 = new Account(Name = 'Test Account 1', Chiffre_d_affaire__c=0);
        insert acc1;

        Account acc2 = new Account(Name = 'Test Account 2', Chiffre_d_affaire__c=0);
        insert acc2;

        List<Account> al = new List<Account>();
            al.add(acc1);
            al.add(acc2);

        Product2 pd1 = new Product2(Name = 'Chemise Verte longue XYX', Family = 'Chemise');
        Insert pd1;

        
        //Create Pricebook
        Pricebook2 pb = new Pricebook2 (Name = 'Test PB002', Description ='Test PB002 Desc', IsActive=true); 
        Insert pb;

        List<Pricebook2> pblist = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Test PB002'];

    
        //Standard pricebook entry 
        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard=true];
        System.debug('Value of standardPB>'+ standardPB.Id);

        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = pd1.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
 

         //Create the PricebookEntry
         PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pblist[0].Id,
            Product2Id = pd1.Id,
            UnitPrice = 1020,
            UseStandardPrice = false, 
            IsActive = true
        );
        Insert pbe;

        List<PricebookEntry> pbelist = [SELECT Id, Pricebook2Id, Product2Id, UnitPrice, IsActive  FROM PricebookEntry];

        
        //Create the Contract
        Contract ctrct = new Contract(
            AccountId = acc1.Id,
            Status='Draft',
            StartDate = Date.newInstance(2021, 4, 1),
            ContractTerm = 24
        );

        Insert ctrct;

        //Create the Contract
        Contract ctrct2 = new Contract(
            AccountId = acc2.Id,
            Status='Draft',
            StartDate = Date.newInstance(2021, 4, 1),
            ContractTerm = 24
        );

        Insert ctrct2;

        //prepare to insert a list of 100 orders
        List<Order> listobase = new List<Order>();
        String crtid='';

        for(Account a:al) {
            if(a.id == acc1.Id){
                crtid=ctrct.Id;

            } else 
            {
                crtid=ctrct2.Id;
            }

            for (Integer i = 0; i<10;i++ ) {

                Order o = new Order(AccountId = a.Id, EffectiveDate=Date.newInstance(2021, 4, 1) , ContractId = crtid, Status='Draft', Pricebook2Id=pblist[0].Id, ShipmentCost__c=350);
                listobase.add(o);
            }

        }

        insert listobase;

        List<Id> accntIds = new List<Id>();
        accntIds.add(acc1.Id);
        accntIds.add(acc2.Id);

        listobase = [SELECT Id,  AccountId, Pricebook2Id FROM Order WHERE Pricebook2Id= :pblist[0].Id AND AccountId IN :accntIds];
        
        //for each order create 1 orderitem line
        Integer qty = 0;
        List<OrderItem> listoibase = new List<OrderItem>();

        List<PricebookEntry> pbeid = [Select Id,  Pricebook2Id from PricebookEntry where PriceBook2Id = :pblist[0].Id];

        for ( Order o :listobase) {
            if (o.AccountId==acc1.Id && o.Pricebook2Id == pblist[0].Id) {
                qty=10;
            } else if (o.Pricebook2Id == pblist[0].Id) {
                qty = 20;
            }

           


            OrderItem oi = new OrderItem(OrderId = o.Id, PricebookEntryId = pbeid[0].Id, Quantity=qty, UnitPrice = 150);
            listoibase.add(oi);
        }


        //dml to insert line items & update orders in bulk 
        insert listoibase;


        Test.startTest();
        
       

        update listobase;
        
        
        
        Test.stopTest();

        Account accnt1TotalAmt = [SELECT Id,Chiffre_d_affaire__c FROM Account where Id =:acc1.Id];
        Account accnt2TotalAmt = [SELECT Id,Chiffre_d_affaire__c FROM Account where Id =:acc2.Id];
        
        List<Order> agr = [SELECT Id  FROM Order];
        

        System.assertEquals(20, agr.size());
        System.assertEquals(0,accnt1TotalAmt.Chiffre_d_affaire__c);
        System.assertEquals(0,accnt2TotalAmt.Chiffre_d_affaire__c);


    }
    
    
}
