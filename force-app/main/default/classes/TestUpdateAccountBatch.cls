@isTest
private class TestUpdateAccountBatch {
    @testSetup
    static void setup() {

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

        //set up 10 accounts
        List<Account> lai = new List<Account>();
        for (Integer i = 0; i<10;i++){
            Account a = new Account(Name = 'Test Account_'+i, Chiffre_d_affaire__c=0, ImportStatus__c='AccountImported');
            lai.add(a);
        }
        insert lai;


        //for each account create 1 contract 
        List<Contract> lci = new List<Contract>();
        for (Account a : lai) {

            Contract c = new Contract(
            AccountId=a.Id,
            Status='Draft',
            StartDate = Date.newInstance(2021, 4, 1),
            ContractTerm = 24
            );

            lci.add(c);
        } 
            insert lci;

        //Map<Id, Contract> mc= new Map<Id,Contract>([Select AccountId, Id from Contract]);  

        //for each account create 6 Orders 
       
        List<Order> loi = new List<Order>(); 
        Integer simTotAmt = 10000;
        for (Account a : lai) {

            for (Integer nborders = 0; nborders <6; nborders++){
             Id crtId = mc.get(a.Id).get('ContractId');   
             Order o = new Order(AccountId = a.Id, EffectiveDate=Date.newInstance(2021, 4, 1) , ContractId = 'b12' , Status='Ordered', Pricebook2Id=pb.Id, ShipmentCost__c=350, TotalAmount=simTotAmt);
             loi.add(o);
             simTotAmt +=100;

            }
             simTotAmt +=1000;
         
        } 
            
            insert loi;
 
    }
    @isTest
    static void test() {
        Test.startTest();
        UpdateAccountsBatch uab = new UpdateAccountsBatch();
        Id batchId = Database.executeBatch(uab);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(60, [select count() from Order]);
        System.assertEquals(0, [select count() from Account where ImportStatus__c = 'OrdersAggregated']);
    }
}