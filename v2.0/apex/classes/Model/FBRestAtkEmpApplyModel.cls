/*
 * Author  : Hiraku Watanabe
 * Company : Fourbs Co. Ltd.
 * Date    : 2023/11/21
 * Purpose : API リクエストによる勤怠申請のオブジェクト操作
 * Deploy  : 
 * Version : 1.0
 * [補足] FBRestAtkEmpApplyCtl クラスから呼び出されるメソッド
*/
public class FBRestAtkEmpApplyModel {

    /**
     * 勤怠申請情報のリスト表示
     */
    public static void doGet() {
        // Restコンテキストの生成、オブジェクトモデルの生成
        FBRestCtx ctx = new FBRestCtx();
        FBSobjectModel mdl = new FBSobjectModel();

        // リクエストの時刻を取得
        DateTime nowDate = DateTime.now();

        // クエリパラメータを取得
        String lastSyncTimeStr = (String) ctx.reqUrlParams.get('lastSyncTime');
        String username = (String) ctx.reqUrlParams.get('username');
        String status = (String) ctx.reqUrlParams.get('status');

        // 勤怠申請情報の取得
        mdl.sqlSelect('teamspirit__StartDate__c, teamspirit__EndDate__c, teamspirit__StartTime__c, teamspirit__EndTime__c, teamspirit__Status__c');
        mdl.sqlSelect('teamspirit__EmpId__r.teamspirit__UserId__r.Username'); // 参照取得: User
        mdl.sqlSelect('teamspirit__HolidayId__r.Name'); // 参照取得: 勤怠休暇
        // 休暇申請のみ取得
        mdl.sqlWhere('teamspirit__HolidayId__c !=', null);
        // 申請ステータスで絞り込み
        if (String.isNotBlank(status)) {
            mdl.sqlWhere('teamspirit__Status__c', status);
        }
        // ユーザ名（メールアドレス）で絞り込み
        if (String.isNotBlank(username)) {
            mdl.sqlWhere('teamspirit__EmpId__r.teamspirit__UserId__r.Username', username);
        }
        // 最終同期日時より後の更新日時で絞り込み
        if (String.isNotBlank(lastSyncTimeStr)) {
            mdl.sqlWhere('LastModifiedDate >=', DateTime.valueOfGmt(lastSyncTimeStr));
        }
        
        // データ取得の実行
        List<teamspirit__AtkEmpApply__c> atkEmpApplyList = mdl.sqlGet('teamspirit__AtkEmpApply__c');

        List<Map<String, Object>> dataList = new List<Map<String, Object>>();
        for (teamspirit__AtkEmpApply__c atkEmpApply : atkEmpApplyList) {
            // パラメータの割り当て
            String  atkEmpApplyId = atkEmpApply.Id;
            String  vacationName = atkEmpApply.teamspirit__HolidayId__r.Name; // 勤怠休暇名: 午前半休, etc.
            Date    startDate    = atkEmpApply.teamspirit__StartDate__c; // 開始日: 2022-05-23 00:00:00
            Date    endDate      = atkEmpApply.teamspirit__EndDate__c;   // 終了日: 2022-05-23 00:00:00
            Integer startTime    = Integer.valueOf(atkEmpApply.teamspirit__StartTime__c); // 開始時刻: 900（分） -> 900/60 -> 15（時） nullable
            Integer endTime      = INteger.valueOf(atkEmpApply.teamspirit__EndTime__c);   // 終了時刻: 1080（分） -> 1080/60 -> 18（時） nullable

            // 返却データの設定
            Map<String, Object> data = new Map<String, Object>();
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
            } else { // 全日有休の場合
                startDtParam.put('dateTime', String.valueOf(startDate) + 'T00:00:00.000Z');
                endDtParam.put('dateTime', String.valueOf(endDate.addDays(1)) + 'T00:00:00.000Z'); // 時刻が 00:00:00 の解釈となるようで、1日分を追加する
            }
            data.put('start', startDtParam);
            data.put('end', endDtParam);
            data.put('latestSyncTimeStr', nowDate);
            data.put('description', 'TeamSpirit Sync.');
            data.put('summary', vacationName);
            data.put('sendNotifications', false);
            data.put('teamspirit__Status__c', atkEmpApply.teamspirit__Status__c);
            data.put('Id', atkEmpApplyId);

            // 返却データに追加
            dataList.add(data);
        }
      
        ctx.setResponse(200, dataList);
    } // End of the method


} // End of the class