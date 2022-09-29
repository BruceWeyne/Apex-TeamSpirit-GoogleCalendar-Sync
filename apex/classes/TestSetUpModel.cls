/*
 * Author  : BruceWeyne, Taku H.F.
 * Purpose : 単体テストの実行時に仮登録するマスタデータ
 * Deploy  :
 * Version : 1.0
*/
@isTest
public class TestSetUpModel {
    /** 実行するユーザ(管理者) */
    public User runAsUser { get; private set;}

    public TestSetUpModel() {
        this.runAsUser = setUpRunAsUser();
    }

    /**
     * 実行するユーザ(管理者)の設定
     * @return [ユーザオブジェクト]
     */
    private User setUpRunAsUser() {
        SobjectModel mdl = new SobjectModel();
        // プロファイルを取得
        mdl.sqlSelect('Id');
        mdl.sqlWhere('Name', Constants.PROFILE_SYSTEM_ADMIN);
        List<Profile> prf = mdl.sqlGet('Profile');
        String prfId = prf[0].Id;
        // RunAs ユーザを設定
        return new User(
            LastName  = 'RunAs',
            FirstName = 'User',
            Alias     = 'RunAs',
            Email     = 'run.as.user@four-brains.com',
            Username  = 'run.as.user@four-brains.com',
            ProfileId = prfId,
            ManagerId = null,
            EmailEncodingKey  = 'Shift_JIS',  // デフォルト
            TimeZoneSidKey    = 'Asia/Tokyo', // デフォルト
            LocaleSidKey      = 'ja_JP',      // デフォルト
            LanguageLocaleKey = 'ja',         // デフォルト
            UserPermissionsMarketingUser = false, // デフォルト
            UserPermissionsOfflineUser   = false // デフォルト
        );
    }

    /**
     * ユーザ・勤怠社員データの初期セットアップ
     * @param  createNum [各データを作成する数量]
     * @return [ユーザ/勤怠社員各オブジェクトリストMap]
     */
    public Map<String, Object> setUpUser(Integer createNum) {
        SobjectModel mdl = new SobjectModel();
        Map<String, Object> userEmpMap = new Map<String, Object>();

        System.runAs(runAsUser) {
            // 勤務基本設定を設定
            teamspirit__AtkConfigBase__c atkConfigBase = new teamspirit__AtkConfigBase__c(
                Name = 'テスト労働',
                teamspirit__InitialDateOfMonth__c = '1',
                teamspirit__InitialDateOfYear__c = '4',
                teamspirit__InitialDayOfWeek__c = '0',
                teamspirit__MarkOfMonth__c = '1',
                teamspirit__MarkOfYear__c = '1',
                teamspirit__Removed__c = false
            );
            insert atkConfigBase;
            // 勤務体系を設定
            teamspirit__AtkEmpType__c atkEmpType = new teamspirit__AtkEmpType__c(
                Name = 'テスト労働',
                teamspirit__AutoProvidePerYear__c = false,
                teamspirit__ConfigBaseId__c = atkConfigBase.Id,
                teamspirit__DaiqAllBorderTime__c = 480,
                teamspirit__DaiqHalfBorderTime__c = 240,
                teamspirit__DaiqLimit__c = 1,
                teamspirit__EnableStockHoliday__c = false,
                teamspirit__NoDaiqExchanged__c = false,
                teamspirit__OverTimeCountAlert__c = 3,
                teamspirit__OverTimeCountLimit__c = 6,
                teamspirit__OverTimeMonthAlert1__c = 900,
                teamspirit__OverTimeMonthAlert2__c = 1200,
                teamspirit__OverTimeMonthAlert3__c = 1500,
                teamspirit__OverTimeMonthLimit__c = 1800,
                teamspirit__OverTimeQuartAlert1__c = 4200,
                teamspirit__OverTimeQuartAlert2__c = 4800,
                teamspirit__OverTimeQuartLimit__c = 5400,
                teamspirit__OverTimeYearAlert1__c = 16800,
                teamspirit__OverTimeYearAlert2__c = 19200,
                teamspirit__OverTimeYearLimit__c = 21600,
                teamspirit__Removed__c = false,
                teamspirit__UseDaiqLegalHoliday__c = true,
                teamspirit__UseDaiqManage__c = true,
                teamspirit__UseDaiqReserve__c = true,
                teamspirit__UseHalfDaiq__c = true,
                teamspirit__UseRegulateHoliday__c = false,
                teamspirit__YuqAssignNoMessages__c = false,
                teamspirit__YuqDate1__c = 401,
                teamspirit__YuqOption__c = '0'
            );
            insert atkEmpType;
            // TSプロファイルを取得
            mdl.sqlSelect('Id');
            mdl.sqlLike('Name', Constants.PROFILE_NAME);
            List<Profile> tsPrf = mdl.sqlGet('Profile');
            String tsPrfId = tsPrf[0].Id;
            // パッケージライセンスを取得
            mdl.sqlSelect('Id');
            mdl.sqlWhere('NamespacePrefix', Constants.PAC_LICENSE_NAME_PREFIX);
            List<PackageLicense> plList = mdl.sqlGet('PackageLicense');
            String plId = plList[0].Id;

            // ユーザを格納する配列
            List<User> userList = new List<User>();

            // ユーザのダミーデータを作成
            for (Integer i = 0; i < (createNum == null ? 3 : createNum); i++) {
                User user = new User(
                    LastName  = '黒崎',
                    FirstName = '太郎' + i,
                    Alias     = 'タロウ' + i,
                    Email     = 'taro.kurosaki' + i + '@four-brains.com',
                    Username  = 'taro.kurosaki' + i + '@four-brains.com',
                    ProfileId = tsPrfId,
                    ManagerId = null,
                    EmployeeNumber    = 'EMP' + i,
                    EmailEncodingKey  = 'Shift_JIS',  // デフォルト
                    TimeZoneSidKey    = 'Asia/Tokyo', // デフォルト
                    LocaleSidKey      = 'ja_JP',      // デフォルト
                    LanguageLocaleKey = 'ja',         // デフォルト
                    UserPermissionsMarketingUser = false, // デフォルト
                    UserPermissionsOfflineUser   = false // デフォルト
                );
                userList.add(user);
            }
            insert userList;

            // ユーザパッケージライセンスを格納する配列
            List<UserPackageLicense> uplList = new List<UserPackageLicense>();
            // 勤怠社員を格納する配列
            List<teamspirit__AtkEmp__c> atkEmpList = new List<teamspirit__AtkEmp__c>();

            for (Integer i = 0; i < userList.size(); i++) {
                // ユーザパッケージライセンスのダミーデータを作成
                UserPackageLicense upl = new UserPackageLicense(
                    UserId = userList.get(i).Id,
                    PackageLicenseId = plId
                );
                uplList.add(upl);

                // 従業員データのダミーデータを作成
                teamspirit__AtkEmp__c atkEmp = new teamspirit__AtkEmp__c(
                    Name = '黒崎太郎' + i,
                    teamspirit__UserId__c    = userList.get(i).Id,
                    teamspirit__EmpTypeId__c = atkEmpType.Id,
                    teamspirit__EmpCode__c   = 'EMP' + i,
                    teamspirit__EntryDate__c = Date.today()
                );
                atkEmpList.add(atkEmp);
            }
            insert uplList;
            insert atkEmpList;

            userEmpMap.put('userList',userList);
            userEmpMap.put('uplList',uplList);
            userEmpMap.put('atkEmpList',atkEmpList);
        }
        return userEmpMap;
    }

    /**
     * 勤怠部署データの初期セットアップ
     * @param  createNum [データを作成する数量]
     * @return [勤怠部署オブジェクトリスト]
     */
    public List<teamspirit__AtkDept__c> setUpDept(Integer createNum) {
        List<teamspirit__AtkDept__c> atkDeptList = new List<teamspirit__AtkDept__c>();

        System.runAs(runAsUser) {
            // 勤怠部署
            for (Integer i = 0; i < (createNum == null ? 3 : createNum); i++) {
                teamspirit__AtkDept__c atkDept = new teamspirit__AtkDept__c(
                    Name = 'テスト部署' + i,
                    teamspirit__DeptCode__c  = 'DPT0000' + i,
                    teamspirit__EndDate__c   = null,
                    teamspirit__ParentId__c  = null,
                    teamspirit__StartDate__c = null
                );
                atkDeptList.add(atkDept);
            }
            insert atkDeptList;
        }
        return atkDeptList;
    }

    /**
     * 勤怠ジョブデータの初期セットアップ
     * @param  createNum [データを作成する数量]
     * @return [勤怠ジョブオブジェクトリスト]
     */
    public List<teamspirit__AtkJob__c> setUpJob(Integer createNum) {
        List<teamspirit__AtkJob__c> atkJobList = new List<teamspirit__AtkJob__c>();

        System.runAs(runAsUser) {
            for (Integer i = 0; i < (createNum == null ? 3 : createNum); i++) {
                // 勤怠ジョブ
                teamspirit__AtkJob__c atkJob = new teamspirit__AtkJob__c(
                    Name = 'テストプロジェクト' + i,
                    teamspirit__JobCode__c = 'PJ0000' + i,
                    teamspirit__StartDate__c = null,
                    teamspirit__EndDate__c = null
                );
                atkJobList.add(atkJob);
            }
            insert atkJobList;
        }
        return atkJobList;
    }

    /**
     * 費目データの初期セットアップ
     * @param  createNum [データを作成する数量]
     * @return [費目オブジェクトリスト]
     */
    public List<teamspirit__AtkExpItem__c> setUpExpItem(Integer createNum) {
        List<teamspirit__AtkExpItem__c> expItemList = new List<teamspirit__AtkExpItem__c>();

        System.runAs(runAsUser) {
            for (Integer i = 0; i < (createNum == null ? 3 : createNum); i++) {
                // 費目
                teamspirit__AtkExpItem__c expItem = new teamspirit__AtkExpItem__c(
                    Name = 'テスト費目' + i,//費目名
                    teamspirit__Code__c  = '00000' + i,//科目コード
                    teamspirit__ItemCode__c   = '000' + i,//費目コード
                    teamspirit__ItemName__c  = 'テスト科目' + i,//科目名
                    teamspirit__TaxCode__c = '00' + i//デフォルト税金コード
                );
                expItemList.add(expItem);
            }
            insert expItemList;
        }
        return expItemList;
    }

} // End of the class