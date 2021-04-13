@isTest
private class TestUpdateAccountBatch {
    @testSetup
    static void setup() {

        //set up 10 accounts
        List<Account> lai = new List<Account>();
        for (Integer i = 0; i<10;i++){
            Account a = new Account(Name = 'Test Account_'+i, Chiffre_d_affaire__c=0, ImportStatus__c='AccountImported');
            lai.add(a);
        }
        insert lai;



       

        
    }
    @isTest
    static void test() {
        Test.startTest();
        UpdateAccountsBatch uab = new UpdateAccountsBatch();
        Id batchId = Database.executeBatch(uab);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(10, [select count() from Account where ImportStatus__c = 'OrdersAggregated']);
    }
}