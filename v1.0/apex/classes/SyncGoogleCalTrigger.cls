/**
 * Author  : BruceWeyne, Taku H.F.
 * Purpose : 休暇申請時に Google カレンダーへ同期する処理
 * Deploy  : 
 * Version : 1.0
*/

trigger SyncGoogleCalTrigger on teamspirit__AtkEmpApply__c (after update) {
    if (Trigger.isInsert) { // レコード挿入の場合
        System.debug(Trigger.new);
    }
    if (Trigger.isUpdate) { // レコード更新の場合
        List<teamspirit__AtkEmpApply__c> atkEmpApplyList = Trigger.new; // 更新したレコードリストを取得
        if (! atkEmpApplyList.isEmpty()) {
            teamspirit__AtkEmpApply__c  atkEmpApply = atkEmpApplyList[0];
            String atkEmpApplyId = atkEmpApply.Id; // 勤怠申請ID
            String applyType = atkEmpApply.teamspirit__ApplyType__c; // 勤怠申請種類
            String applyStatus = atkEmpApply.teamspirit__Status__c;  // 勤怠申請ステータス

            if (applyType == '休暇申請' && applyStatus == '承認済み') { // 承認済みの場合
                SyncGoogleCalHandler.handlePostGoogleCal(atkEmpApplyId);
            } else if (applyType == '休暇申請' && applyStatus == '申請取消') { // 申請が取り消された場合
                SyncGoogleCalHandler.handleDeleteGoogleCal(atkEmpApplyId);
            }
        }
    }
    if (Trigger.isDelete) { // レコード削除の場合
        System.debug(Trigger.old);
    }


} // End of the trigger