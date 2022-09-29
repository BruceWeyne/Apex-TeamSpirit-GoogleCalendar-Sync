/*
 * Author  : BruceWeyne, Taku H.F.
 * Purpose : SyncGoogleCalTrigger, SyncGoogleCalHandler の単体テスト
 * Deploy  : 
 * Version : 1.0
*/
@isTest
public class TestSyncGoogleCalTrigger {


    /**
     * テストデータのセットアップ
     */
    @testSetUp
    static void setUpMethod() {
        // マスタデータのセットアップ
        TestSetUpModel setup = new TestSetUpModel();
        Map<String, Object> userEmpMap = setup.setUpUser(3); // ユーザと従業員の作成
        // 上長を設定
        List<teamspirit__AtkEmp__c> atkEmpList = (List<teamspirit__AtkEmp__c>)userEmpMap.get('atkEmpList');
        String atkEmpUserId_manager = atkEmpList[2].teamspirit__UserId__c; // マネージャとなる従業員のユーザID
        atkEmpList[0].teamspirit__Manager__c = atkEmpUserId_manager; // マネージャを設定
        update atkEmpList;
    }


    /**
     * 勤怠申請オブジェクトの更新（終日有休）
     * 
     */
    @isTest
    static void updateAtkEmpApply_wholeDay() {
        SOQLBuilder sb = new SOQLBuilder();
        // 勤怠申請オブジェクトの作成
        teamspirit__AtkEmpApply__c atkEmpApply = new teamspirit__AtkEmpApply__c();
        // 従業員の取得
        sb.sqlSelect('Id');
        List<teamspirit__AtkEmp__c> atkEmpList = sb.sqlGet('teamspirit__AtkEmp__c');
        String atkEmpId = atkEmpList[0].Id;
        // 勤怠申請オブジェクトへパラメータを設定
        atkEmpApply.put('teamspirit__EmpId__c', atkEmpId);
        atkEmpApply.put('teamspirit__ApplyType__c', '休暇申請');
        atkEmpApply.put('teamspirit__Status__c', '承認待ち');
        atkEmpApply.put('teamspirit__StartDate__c', Date.today());
        atkEmpApply.put('teamspirit__EndDate__c', Date.today());
        // Web サービスコールアウト疑似応答の設定
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        // テスト開始
        Test.startTest();
        // データの挿入
        insert atkEmpApply;
        // 承認済みへステータス変更
        atkEmpApply.put('teamspirit__Status__c', '承認済み');
        update atkEmpApply;
        Test.stopTest();
        // テストの検証
        sb.sqlSelect('Id');
        sb.sqlWhere('AtkEmpApplyId__c', atkEmpApply.Id);
        List<GoogleCalendarEvent__c> gceList = sb.sqlGet('GoogleCalendarEvent__c');
        System.assertEquals(false, gceList.isEmpty());
    }


    /**
     * 勤怠申請オブジェクトの更新（時間有休）
     * 
     */
    @isTest
    static void updateAtkEmpApply_timeRange() {
        SOQLBuilder sb = new SOQLBuilder();
        // 勤怠申請オブジェクトの作成
        teamspirit__AtkEmpApply__c atkEmpApply = new teamspirit__AtkEmpApply__c();
        // 従業員の取得
        sb.sqlSelect('Id');
        List<teamspirit__AtkEmp__c> atkEmpList = sb.sqlGet('teamspirit__AtkEmp__c');
        String atkEmpId = atkEmpList[0].Id;
        // 勤怠申請オブジェクトへパラメータを設定
        atkEmpApply.put('teamspirit__EmpId__c', atkEmpId);
        atkEmpApply.put('teamspirit__ApplyType__c', '休暇申請');
        atkEmpApply.put('teamspirit__Status__c', '承認待ち');
        atkEmpApply.put('teamspirit__StartDate__c', Date.today());
        atkEmpApply.put('teamspirit__EndDate__c', Date.today());
        atkEmpApply.put('teamspirit__StartTime__c', 840);
        atkEmpApply.put('teamspirit__EndTime__c', 960);
        // Web サービスコールアウト疑似応答の設定
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        // テスト開始
        Test.startTest();
        // データの挿入
        insert atkEmpApply;
        // 承認済みへステータス変更
        atkEmpApply.put('teamspirit__Status__c', '承認済み');
        update atkEmpApply;
        Test.stopTest();
        // テストの検証
        sb.sqlSelect('Id');
        sb.sqlWhere('AtkEmpApplyId__c', atkEmpApply.Id);
        List<GoogleCalendarEvent__c> gceList = sb.sqlGet('GoogleCalendarEvent__c');
        System.assertEquals(false, gceList.isEmpty());
    }




    /**
     * 勤怠申請オブジェクトの更新（イベント削除）
     * 
     */
    @isTest
    static void updateAtkEmpApply_delete() {
        SOQLBuilder sb = new SOQLBuilder();
        // 勤怠申請オブジェクトの作成
        teamspirit__AtkEmpApply__c atkEmpApply = new teamspirit__AtkEmpApply__c();
        // Google カレンダーイベントオブジェクトの作成
        GoogleCalendarEvent__c gce = new GoogleCalendarEvent__c();
        // 従業員の取得
        sb.sqlSelect('Id');
        List<teamspirit__AtkEmp__c> atkEmpList = sb.sqlGet('teamspirit__AtkEmp__c');
        String atkEmpId = atkEmpList[0].Id;
        // 勤怠申請オブジェクトへパラメータを設定
        atkEmpApply.put('teamspirit__EmpId__c', atkEmpId);
        atkEmpApply.put('teamspirit__ApplyType__c', '休暇申請');
        atkEmpApply.put('teamspirit__Status__c', '承認待ち');
        atkEmpApply.put('teamspirit__StartDate__c', Date.today());
        atkEmpApply.put('teamspirit__EndDate__c', Date.today());
        // Web サービスコールアウト疑似応答の設定
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        // テスト開始
        Test.startTest();
        // データの挿入
        insert atkEmpApply;
        gce.put('GCalEventId__c', '0aDTqp6RuLLoh7GddSJo88R6WTVYMclI');
        gce.put('AtkEmpApplyId__c', atkEmpApply.Id);
        insert gce;
        // 申請取消へステータス変更
        atkEmpApply.put('teamspirit__Status__c', '申請取消');
        update atkEmpApply;
        Test.stopTest();
        // テストの検証
        sb.sqlSelect('Id');
        sb.sqlWhere('AtkEmpApplyId__c', atkEmpApply.Id);
        List<GoogleCalendarEvent__c> gceList = sb.sqlGet('GoogleCalendarEvent__c');
        System.assertEquals(true, gceList.isEmpty());
    }


} // End of the class