@isTest
private class TestUpdateAccountBatch {
    @testSetup
    static void setup() {

        //Create Pricebook
        Pricebook2 pb = new Pricebook2 (Name = 'Test PB001', Description ='Test PB001 Desc', IsActive=true); 
        Insert pb;

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


        //for each account create 6 Orders 
        List<Order> loi = new List<Order>(); 
        Currency simTotAmt = 10000;
        for (Account a : lai) {

            for (Integer nborders = 0; nborders <6; nmborders++){
             Order o = new Order(AccountId = a.Id, EffectiveDate=Date.newInstance(2021, 4, 1) , ContractId = a.ContractId, Status='Ordered', Pricebook2Id=pb.Id, ShipmentCost__c=350);
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
        System.assertEquals(60, [select count() from Orders]);
        System.assertEquals(0, [select count() from Account where ImportStatus__c = 'OrdersAggregated']);
    }
}