@isTest
private class TestUpdateAccountTurnover {
    @isTest(SeeAllData=True)
    static void should_aggregate_two_orders_on_account() {
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

            for (Integer i = 0; i<100;i++ ) {

                Order o = new Order(AccountId = a.Id, EffectiveDate=Date.newInstance(2021, 4, 1) , ContractId = crtid, Status='Draft', Pricebook2Id=pb.Id, ShipmentCost__c=350);
                listobase.add(o);
            }

        }

        insert listobase;

        listobase = [SELECT Id FROM Order];
        
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
        
        /*Order o1 = new Order(AccountId = acc1.Id, EffectiveDate=Date.newInstance(2021, 4, 1) , ContractId = ctrct.Id, Status='Draft', Pricebook2Id=pb.Id, ShipmentCost__c=350);
        insert o1;
        Order o2 = new Order(AccountId = acc2.Id, EffectiveDate=Date.newInstance(2021, 4, 1) , ContractId = ctrct2.Id, Status='Draft', Pricebook2Id=pb.Id, ShipmentCost__c=650);
        insert o2;

        

        OrderItem oi1 = new OrderItem (OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity=10, UnitPrice = 150);
        insert oi1;
        OrderItem oi2 = new OrderItem (OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity=20, UnitPrice = 1000);
        insert oi2; 
        
        OrderItem o2i1 = new OrderItem (OrderId = o2.Id, PricebookEntryId = pbe.Id, Quantity=50, UnitPrice = 150);
        insert o2i1;
        OrderItem o2i2 = new OrderItem (OrderId = o2.Id, PricebookEntryId = pbe.Id, Quantity=70, UnitPrice = 1000);
        insert o2i2; 
        
        List<Order> listo = new List<Order>();
        listo.add(o1);
        listo.add(o2);

        update listo;

         */

        update listobase;
        
        
        
        Test.stopTest();

        Account accnt1TotalAmt = [SELECT Id,Chiffre_d_affaire__c FROM Account where Id =:acc1.Id];
        Account accnt2TotalAmt = [SELECT Id,Chiffre_d_affaire__c FROM Account where Id =:acc2.Id];
        
        List<Order> agr = [SELECT Id  FROM Order];
        

        System.assertEquals(200, agr.size());
        System.assertEquals(150000,accnt1TotalAmt.Chiffre_d_affaire__c);
        System.assertEquals(300000,accnt2TotalAmt.Chiffre_d_affaire__c);


    }

    //missing assert statement on unitary order case 
    //missing case where adding order on account having 100+ orders
    //not using bulkified statement
    
}
