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
        Pricebook2 pb = new Pricebook2 (Name = 'Test PB001', Description ='Test PB001 Desc', IsActive=true); 
        Insert pb;

        //Create the PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = pd1.Id,
            UnitPrice = 1020,
            UseStandardPrice = false, 
            IsActive = true
        );
        Insert pbe;


        
        //Standard pricebook entry 
        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard=true];
        System.debug('Value of standardPB>'+ standardPB.Id);

        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = pd1.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
 

        
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

                Order o = new Order(AccountId = a.Id, EffectiveDate=Date.newInstance(2021, 4, 1) , ContractId = crtid, Status='Ordered', Pricebook2Id=pb.Id, ShipmentCost__c=350);
                listobase.add(o);
            }

        }

        insert listobase;

        listobase = [SELECT Id, AccountId FROM Order];
        
        //for each order create 1 orderitem line
        Integer qty = 0;
        List<OrderItem> listoibase = new List<OrderItem>();
        for ( Order o :listobase) {
            if (o.AccountId==acc1.Id) {
                qty=10;
            } else {
                qty = 20;
            }

            Id pbeid = [Select Id from PricebookEntry where PriceBook2Id = :pb.id];

            OrderItem oi = new OrderItem(OrderId = o.Id, PricebookEntryId = pbeid, Quantity=qty, UnitPrice = 150);
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
        Pricebook2 pb = new Pricebook2 (Name = 'Test PB001', Description ='Test PB001 Desc', IsActive=true); 
        Insert pb;
        
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

                Order o = new Order(AccountId = a.Id, EffectiveDate=Date.newInstance(2021, 4, 1) , ContractId = crtid, Status='Draft', Pricebook2Id=pb.Id, ShipmentCost__c=350);
                listobase.add(o);
            }

        }

        insert listobase;

        listobase = [SELECT Id, AccountId FROM Order];
        
        //for each order create 1 orderitem line
        Integer qty = 0;
        List<OrderItem> listoibase = new List<OrderItem>();
        for ( Order o :listobase) {
            if (o.AccountId==acc1.Id) {
                qty=10;
            } else {
                qty = 20;
            }

            OrderItem oi = new OrderItem(OrderId = o.Id, PricebookEntryId = pbe.Id, Quantity=qty, UnitPrice = 150);
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
