/*
 * Author  : Hiraku Watanabe
 * Company : Fourbs Co. Ltd.
 * Date    : 2023/11/21
 * Purpose : 勤怠申請の REST API エンドポイントの定義
 * Deploy  : 
 * Version : 1.0
*/
@RestResource(urlMapping='/test/v1.0/sobjects/teamspirit__AtkEmpApply__c/*')
global with sharing class FBRestAtkEmpApplyCtl {

    /**
     * 勤怠申請情報のリスト表示
     */
    @HttpGet
    global static void handleGetRequest() {
        FBRestAtkEmpApplyModel.doGet();
    } // End of the method

} // End of the class