@isTest
private class TestUpdateAccountTurnover {
    @isTest(SeeAllData=True)
    static void should_aggregate_two_orders_on_account() {
        Account acc1 = new Account(Name = 'Test Account 1');
        insert acc1;

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


        Test.startTest();
        Order o1 = new Order(AccountId = acc1.Id, EffectiveDate=Date.newInstance(2021, 4, 1) , ContractId = ctrct.Id, Status='Draft', Pricebook2Id=pb.Id );

        insert o1;

        OrderItem oi1 = new OrderItem (OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity=10, UnitPrice = 150);
        insert oi1;
        OrderItem oi2 = new OrderItem (OrderId = o1.Id, PricebookEntryId = pbe.Id, Quantity=20, UnitPrice = 1000);
        insert oi2;        

    
        Test.stopTest();

        List<Order> agr = [SELECT Id  FROM Order];
        

        System.assertEquals(1, agr.size());

    }

    //missing assert statement on unitary order case 
    //missing case where adding order on account having 100+ orders
    //not using bulkified statement
    
}
