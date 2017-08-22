/**
 * Created by dell on 7/25/2017.
 */

@IsTest
private class AccountHandlerTest {
    static testMethod void testAddAccShare() {
        List<AccountShare> accountShares = new List<AccountShare>();
        AccountShare acc = AccountHandler.addAccShare('0010Y00000YAEj3QAH', '0050Y000002GnWJQA0');
        accountShares.add(acc);
        System.assertEquals(accountShares.size(), 1);
    }

    static testMethod void testGetAllChildren(){
        Test.startTest();
        Terr__c terr = new Terr__c(Name = 'testTerr');
        insert terr;
        Terr__c terrP = new Terr__c(Name = 'testTerrP', PerentTerr__c = terr.Id);
        insert terrP;
        UserTerr__c userTerr = new UserTerr__c(Terr__c = terrP.Id, User__c = '0050Y000002GnZ3QAK');
        insert userTerr;
        AccountHandler.getAllChildren(terr.Id);
        System.assertEquals(AccountHandler.allChildTerrs.size(), 2);
        Test.stopTest();
    }

    static testMethod void testInsertUpdateAccount() {
        Test.startTest();
        Terr__c terr = new Terr__c(Name = 'testTerr');
        insert terr;
        Account account = new Account(Name = 'TestAcc', Terr__c = terr.Id);
        insert account;
        account = new Account(id = account.Id, Name = 'TestAcc2', Terr__c = terr.Id);
        update account;
        Test.stopTest();
    }

    static testMethod void testInsertUpdateDeleteUserTerr() {
        Test.startTest();
        Terr__c terr = new Terr__c(Name = 'testTerr');
        insert terr;
        UserTerr__c userTerr = new UserTerr__c(Terr__c = terr.Id, User__c = '0050Y000002GnZ3QAK');
        insert userTerr;
        userTerr = new UserTerr__c(id = userTerr.Id, Terr__c = terr.Id, User__c = '0050Y000002GnZ3QAK');
        update userTerr;
        delete userTerr;
        Test.stopTest();
    }

    static testMethod void testInsertUpdateDeleteReference() {
        Test.startTest();
        Terr__c terr = new Terr__c(Name = 'testTerr');
        insert terr;
        Account account = new Account(Name = 'TestAcc', Terr__c = terr.Id);
        insert account;
        Account account2 = new Account(Name = 'TestAcc2', Terr__c = terr.Id);
        insert account2;
        Contact contact = new Contact(LastName = 'testContact', AccountId = account.Id);
        insert contact;
        Reference__c reference = new Reference__c(Account__c = account.Id, Contact__c = contact.Id);
        insert reference;
        reference = new Reference__c(id = reference.Id, Account__c = account2.Id, Contact__c = contact.Id);
        update reference;
        delete reference;
        Test.stopTest();
    }

}