/**
 * Created by dell on 7/22/2017.
 */

public with sharing class AccountHandler {
    public static String idTerrString = '';
    public static List<Terr__c> allChildTerrs = new List<Terr__c>();

    //----------------------------Select all children ib Terr------------------------------------------

    public static void getAllChildren(String idString) {
        allChildTerrs.clear();
        List<Terr__c> perentTerrs =[
                SELECT
                        Id
                FROM Terr__c
                WHERE Id = :idString
        ];
        allChildTerrs.addAll(perentTerrs);
        getTerrChild(perentTerrs);
    }

    public static void getTerrChild(List<Terr__c> lst) {
        List<Terr__c> lstChilds = [
                SELECT
                        id
                FROM Terr__c
                WHERE PerentTerr__c in :lst
        ];
        if (lstChilds.size() > 0) {
            allChildTerrs.addAll(lstChilds);
            getTerrChild(lstChilds);
        }
    }

    //-------------------------Select all users who are granted access to the territories-----------------------

    public static List<UserTerr__c> getAllUsersWithAccessTerr() {
        return [
                SELECT
                        User__c
                FROM UserTerr__c
                WHERE Terr__c in :allChildTerrs
        ];
    }

    //-------------------------Add to AccountShare granted access to user  -----------------------
    //-------------------------------------------CRUD AccountShare--------------------------------

    public static void addAccountShare(List<Account> AccountId) {
        List<AccountShare> shareList = new List<AccountShare>();
        for (Account acc : AccountId) {
            getAllChildren(acc.Terr__c);
            for (UserTerr__c user : getAllUsersWithAccessTerr()) {
                AccountShare accountShare = addAccShare(acc.Id, user.User__c);
                shareList.add(accountShare);
            }
        }
        ifShareListNotEmptyInsert(shareList);
    }

    public static Boolean isAccountUpdateTerrBoolean(List<Account> newTrigger, List<Account> oldTrigger) {
        for (Account accNew : newTrigger) {
            for (Account accOld : oldTrigger) {
                if (accNew.Terr__c != accOld.Terr__c) {
                    return true;
                }
            }
        }
        return false;
    }

    public static void updateAccountShare(List<Account> newTrigger, List<Account> oldTrigger) {
        if (isAccountUpdateTerrBoolean(newTrigger, oldTrigger)) {
            delAccountShare(oldTrigger);
            addAccountShare(newTrigger);
        }
    }

    public static void delAccountShare(List<Account> AccountId) {
        List<AccountShare> shareList = getListAccountSharesFromListAccountId(AccountId);
        System.debug(shareList);
        ifShareListNotEmptyDelete(shareList);
    }

    public static List<AccountShare> getListAccountSharesFromListAccountId(List<Account> accounts) {
        List<AccountShare> shareList = [
                SELECT
                        id
                FROM AccountShare
                WHERE AccountId = :accounts
                and RowCause = 'Manual'
        ];
        return shareList;
    }

    //-------------------------Add to AccountShare granted access to User to Contact   -------------
    //----------------------------------CRUD to table Reference__c---------------------------------

    public static void addAccountShareToContact(List<Reference__c> references) {
        if (!selectAccountShareToContact(references).isEmpty()) {
            insert selectAccountShareToContact(references);
        }
    }

    public static void delAccountShareToContact(List<Reference__c> references) {
        List<AccountShare> listUsers = getListUserWhoHaveAccessToAccountContact(references);
        List<User> users = new List<User>();
        for (AccountShare user : listUsers) {
            users.add(new User(id = user.UserOrGroupId));
        }
        List<AccountShare> shareList = [
                SELECT
                        id
                FROM AccountShare
                WHERE AccountId = :references.get(0).Account__c
                and UserOrGroupId in :users
                and RowCause = 'Manual'
        ];
        ifShareListNotEmptyDelete(shareList);
    }

    public static void updateAccountShareToContact(List<Reference__c> newTrigger, List<Reference__c> oldTrigger) {
        delAccountShareToContact(oldTrigger);
        addAccountShareToContact(newTrigger);
    }

    public static List<AccountShare> selectAccountShareToContact(List<Reference__c> references) {
        List<AccountShare> shareList = new List<AccountShare>();
        List<AccountShare> listUsers = getListUserWhoHaveAccessToAccountContact(references);
        for (AccountShare user : listUsers) {
            AccountShare accountShare = addAccShare(references.get(0).Account__c, user.UserOrGroupId);
            shareList.add(accountShare);
        }
        return shareList;
    }

    public static List<AccountShare> getListUserWhoHaveAccessToAccountContact(List<Reference__c> references) {
        return [
                Select
                        UserOrGroupId
                from AccountShare
                where AccountId = :[
                        SELECT
                                AccountId
                        From Contact
                        where id = :references.get(0).Contact__c
                ].get(0).AccountId
                and RowCause = 'Manual'
        ];
    }

    //----------------------------------CRUD to table UserTerr__c---------------------------------

    public static void addAccountShareBecouseCreateUserTerr(List<UserTerr__c> userTerr) {
        List<AccountShare> shareList = new List<AccountShare>();
        getAllChildren(userTerr.get(0).Terr__c);
        List<Account> accounts = getListAccountFromListTerrId(allChildTerrs);
        for (Account acc : accounts) {
            AccountShare accountShare = addAccShare(acc.Id, userTerr.get(0).User__c);
            shareList.add(accountShare);
        }
        ifShareListNotEmptyInsert(shareList);
    }

    public static List<Account> getListAccountFromListTerrId(List<Terr__c> allChildTerrs) {
        return [
                SELECT
                        id
                FROM Account
                WHERE Terr__c in :allChildTerrs
        ];
    }

    public static void updateAccountShareBecouseUpdateUserTerr(
            List<UserTerr__c> newTrigger, List<UserTerr__c> oldTrigger) {
        delAccountShareBecouseDeleteUserTerr(oldTrigger);
        addAccountShareBecouseCreateUserTerr(newTrigger);
    }

    public static void delAccountShareBecouseDeleteUserTerr(List<UserTerr__c> oldTrigger) {
        DeleteAllAccountShareByUser(oldTrigger);
        List<Terr__c> lstTerrs = selectListTerrGrantedUser(oldTrigger);
        List<Account> accountsInsert = getListAccountFromListTerrId(lstTerrs);
        List<AccountShare> shareListInsert = new List<AccountShare>();
        for (Account acc : accountsInsert) {
            AccountShare accountShare = addAccShare(acc.Id, oldTrigger.get(0).User__c);
            shareListInsert.add(accountShare);
        }
        ifShareListNotEmptyInsert(shareListInsert);
    }

    public static void DeleteAllAccountShareByUser(List<UserTerr__c> oldTrigger) {
        getAllChildren(oldTrigger.get(0).Terr__c);
        List<Account> accountsDelete = getListAccountFromListTerrId(allChildTerrs);
        List<AccountShare> shareList = getListAccountSharesFromListAccountId(accountsDelete);
        ifShareListNotEmptyDelete(shareList);
    }

    public static List<Terr__c> selectListTerrGrantedUser(List<UserTerr__c> oldTrigger) {
        List<Terr__c> lstTerrs = new List<Terr__c>();
        List<UserTerr__c> uTerrs = [
                SELECT
                        Id,
                        Terr__c
                FROM UserTerr__c
                WHERE User__c = :oldTrigger.get(0).User__c
        ];
        allChildTerrs.clear();
        for (UserTerr__c userTerr : uTerrs) {
            allChildTerrs.add(new Terr__c(id = userTerr.Terr__c));
            List<Terr__c> terrs = new List<Terr__c>();
            terrs.add(new Terr__c(id = userTerr.Terr__c));
            getTerrChild(terrs);
            for (Terr__c terr : allChildTerrs) {
                lstTerrs.add(terr);
            }
        }
        return lstTerrs;
    }

    public static void ifShareListNotEmptyInsert(List<AccountShare> shareList) {
        if (!shareList.isEmpty()) {
            insert shareList;
        }
    }

    public static void ifShareListNotEmptyDelete(List<AccountShare> shareList) {
        if (!shareList.isEmpty()) {
            delete shareList;
        }
    }

    public static AccountShare addAccShare(String AccountIdS, String UserOrGroupIdS){
        AccountShare accountShare = new AccountShare();
        accountShare.AccountId = AccountIdS;
        accountShare.UserOrGroupId = UserOrGroupIdS;
        accountShare.AccountAccessLevel = 'Edit';
        accountShare.CaseAccessLevel = 'Edit';
        accountShare.OpportunityAccessLevel = 'Edit';
        return accountShare;
    }

//------------------------------------------------------------------------------------------------------
}