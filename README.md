TeamSpirit Google Calendar Sync. Project
===
TeamSpirit での休暇申請を Google カレンダーへ同期させる

# 前提条件
[Apex SOQLBuilder](https://github.com/BruceWeyne/Apex-SOQLBuilder) を活用しています。<br>
SOQLBuilder クラスも同時に Salesforce 環境へアップロードしてください。

# カスタムオブジェクトの作成
TeamSpirit での有給休暇申請を Google カレンダーへ同期させるためのステータス管理オブジェクト

### [表示ラベル]
Googleカレンダーイベント<br>
### [API 参照名]
GoogleCalendarEvent__c (※ "__c" は自動で付与される)<br>
### [種別]
カスタムオブジェクト<br>
### [説明]
TeamSpirit での有給休暇申請を Google カレンダーへ同期させるためのステータス管理オブジェクト

## カスタムオブジェクトのフィールド

|表示ラベル|API 参照名|データ型|説明|
|-|-|-|-|
|Googleカレンダーイベント|Name|テキスト(80)||
|イベントID|GCalEventId__c|ロングテキストエリア(1024)|Googleカレンダーでイベントを登録した際に発行されるID|
|勤怠申請ID|AtkEmpApplyId__c|参照関係(勤怠申請)|TeamSpirit勤怠申請のオブジェクトID|

# 認証規格
GCP OAuth2.0

# 参考記事
- [SalesforceからGoogleCalendarを設定する方法(指定ログイン情報を利用した連携)](https://web.plus-idea.net/2017/01/salesforce-google-calendar-rest/)
- [Google Calendar API](https://developers.google.com/calendar/api/v3/reference)