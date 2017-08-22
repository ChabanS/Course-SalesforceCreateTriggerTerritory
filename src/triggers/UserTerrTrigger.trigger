/**
 * Created by dell on 7/23/2017.
 */

trigger UserTerrTrigger on UserTerr__c (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter){
        if (Trigger.isInsert || Trigger.isUndelete) {
            AccountHandler.addAccountShareBecouseCreateUserTerr(Trigger.new);
        }

        if (Trigger.isUpdate) {
            AccountHandler.updateAccountShareBecouseUpdateUserTerr(Trigger.new, Trigger.old);
        }

        if (Trigger.isDelete) {
            AccountHandler.delAccountShareBecouseDeleteUserTerr(Trigger.old);
        }
    }
}