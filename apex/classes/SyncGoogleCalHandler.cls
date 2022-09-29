/**
 * Author  : BruceWeyne, Taku H.F.
 * Purpose : Google カレンダーの API 操作
 * Deploy  : 
 * Version : 1.0
 * [Reference]
 * https://web.plus-idea.net/2017/01/salesforce-google-calendar-rest/
 * https://developers.google.com/calendar/api/v3/reference
*/

public class SyncGoogleCalHandler {
    private static final String credentialName = 'GoogleCalLogIn'; // 指定ログイン情報名

    /**
     * @description Google カレンダーへ該当イベントを登録
     * @param {String} atkEmpApplyId [勤怠申請のオブジェクトID]
     */
    @future(callout=true)
    public static void handlePostGoogleCal(String atkEmpApplyId) {
        SOQLBuilder sb = new SOQLBuilder();
        HttpRequest req = new HttpRequest();
        Http http = new Http();

        // Sandbox 環境かどうかの検証用
        sb.sqlSelect('Id, IsSandBox');
        sb.sqlLimit(1);
        List<Organization> orgList = sb.sqlGet('Organization');
        Organization org = orgList[0];

        // 勤怠申請情報の取得
        sb.sqlSelect('teamspirit__StartDate__c, teamspirit__EndDate__c, teamspirit__StartTime__c, teamspirit__EndTime__c');
        sb.sqlSelect('teamspirit__EmpId__r.teamspirit__UserId__r.Username'); // 参照取得: User
        sb.sqlSelect('teamspirit__HolidayId__r.Name'); // 参照取得: 勤怠休暇
        sb.sqlWhere('Id', atkEmpApplyId);
        List<teamspirit__AtkEmpApply__c> atkEmpApplyList = sb.sqlGet('teamspirit__AtkEmpApply__c');
        if (atkEmpApplyList.isEmpty()) {
            return;
        }
        teamspirit__AtkEmpApply__c atkEmpApply = atkEmpApplyList[0];

        // パラメータの割り当て
        String  vacationName = atkEmpApply.teamspirit__HolidayId__r.Name; // 勤怠休暇名: 午前半休, etc.
        String  userName     = atkEmpApply.teamspirit__EmpId__r.teamspirit__UserId__r.Username; // ユーザ名: ****@four-brains.com
        Date    startDate    = atkEmpApply.teamspirit__StartDate__c; // 開始日: 2022-05-23 00:00:00
        Date    endDate      = atkEmpApply.teamspirit__EndDate__c;   // 終了日: 2022-05-23 00:00:00
        Integer startTime    = Integer.valueOf(atkEmpApply.teamspirit__StartTime__c); // 開始時刻: 900（分） -> 900/60 -> 15（時） nullable
        Integer endTime      = INteger.valueOf(atkEmpApply.teamspirit__EndTime__c);   // 終了時刻: 1080（分） -> 1080/60 -> 18（時） nullable

        // API リクエストの設定
        String calId = org.IsSandBox ? userName.substringBeforeLast('.') : userName; // SandBox 環境の場合に付く末尾の SandBox 名を削除
		String reqPath = 'callout:' + credentialName + '/calendars/' + calId + '/events'; // API エンドポイント
        
        // リクエストボディの設定
        Map<String, Object> reqBody = new Map<String, Object>();
        Map<String, Object> startDtParam = new Map<String, Object>();
        Map<String, Object> endDtParam = new Map<String, Object>();
        if (startTime != null && endTime != null) { // 時間有休の場合
            Integer  baseline = 60;
            String   convStartTime = String.valueOf(startTime / baseline) + ':' + String.valueOf(Math.mod(startTime, baseline)) + ':00+09:00'; // 10:00:00+09:00
            String   convEndTime   = String.valueOf(endTime / baseline) + ':' + String.valueOf(Math.mod(endTime, baseline)) + ':00+09:00';     // 10:00:00+09:00
            Datetime startDt       = Datetime.valueOf(String.valueOf(startDate) + ' ' + convStartTime); // 2022-06-06T10:00:00+09:00
            Datetime endDt         = Datetime.valueOf(String.valueOf(endDate) + ' ' + convEndTime);     // 2022-06-06T10:00:00+09:00
            startDtParam.put('dateTime', startDt);
            endDtParam.put('dateTime', endDt);
            reqBody.put('summary', vacationName);
        } else { // 全日有休の場合
            startDtParam.put('date', String.valueOf(startDate));
            endDtParam.put('date', String.valueOf(endDate.addDays(1))); // 時刻が 00:00:00 の解釈となるようで、1日分を追加する
            reqBody.put('summary', vacationName);
        }
        reqBody.put('start', startDtParam);
        reqBody.put('end', endDtParam);
        reqBody.put('description', 'TeamSpirit Sync.');
        reqBody.put('sendNotifications', false);

        String jsonBody = JSON.serialize(reqBody);

        req.setEndpoint(reqPath);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonBody);
        // [完成形イメージ]
        // req.setBody('{ "end": {  "dateTime": "2022-06-06T11:00:00+09:00" }, "start": {  "dateTime": "2022-06-06T10:00:00+09:00" }, "description": "TeamSpirit Sync.", "summary": "午前半休"}');
        
        // API の実行
        HTTPResponse res = http.send(req);
        Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

        // 成功した場合
        if (res.getStatusCode() == 200) {
            String gCalEventId = (String)resBody.get('id');
            GoogleCalendarEvent__c gce = new GoogleCalendarEvent__c();
            gce.AtkEmpApplyId__c = atkEmpApplyId;
            gce.GCalEventId__c = gCalEventId;
            upsert gce; // カスタムオブジェクトに勤怠申請IDと Google カレンダーIDを紐づけて格納（削除時に必要）
        }
    }

    /**
     * @description Google カレンダーから該当イベントを削除
     * @param {String} atkEmpApplyId [勤怠申請のオブジェクトID]
     */
    @future(callout=true)
    public static void handleDeleteGoogleCal(String atkEmpApplyId) {
        SOQLBuilder sb = new SOQLBuilder();
        HttpRequest req = new HttpRequest();
        Http http = new Http();

        // Sandbox 環境かどうかの検証用
        sb.sqlSelect('Id, IsSandBox');
        sb.sqlLimit(1);
        List<Organization> orgList = sb.sqlGet('Organization');
        Organization org = orgList[0];

        // カスタムオブジェクトから勤怠申請IDに紐づく Google カレンダーIDを取得
        sb.sqlSelect('GCalEventId__c');
        sb.sqlSelect('AtkEmpApplyId__r.teamspirit__EmpId__r.teamspirit__UserId__r.Username'); // 参照取得: 勤怠申請
        sb.sqlWhere('AtkEmpApplyId__c', atkEmpApplyId);
        List<GoogleCalendarEvent__c> gceList = sb.sqlGet('GoogleCalendarEvent__c');
        // レコードが存在しない場合は処理終了
        if (gceList.isEmpty()) {
            return;
        }
        // パラメータの割り当て
        GoogleCalendarEvent__c gce = gceList[0];
        String gCalEventId = gce.GCalEventId__c;
        String userName    = gce.AtkEmpApplyId__r.teamspirit__EmpId__r.teamspirit__UserId__r.Username; // ユーザ名: ****@four-brains.com

        // API リクエストの設定
        String calId = org.IsSandBox ? userName.substringBeforeLast('.') : userName; // SandBox 環境の場合に付く末尾の SandBox 名を削除
		String reqPath = 'callout:' + credentialName + '/calendars/' + calId + '/events/'; // API エンドポイント
         
        // API の実行
        req.setEndpoint(reqPath + gCalEventId);
        req.setMethod('DELETE');
        HTTPResponse res = http.send(req);

        // 成功した場合
        if (res.getStatusCode() == 204) {
            delete gceList;
        }
    }


} // End of the class