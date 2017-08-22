/**
 * Created by dell on 7/22/2017.
 */

trigger AccountTrigger on Account (after insert, after update) {

    if (Trigger.isAfter){
        if (Trigger.isInsert){
            AccountHandler.addAccountShare(Trigger.new);
        }

        if(Trigger.isUpdate){
            AccountHandler.updateAccountShare(Trigger.new, Trigger.old);
        }
    }
}