<?php
#アプリからデータ受信
if($_SERVER['REQUEST_METHOD'] != 'POST')die('サーバーへの接続に失敗しました');
$email = $_POST['email'];
$password = $_POST['password'];
$groupName = $_POST['groupName'];
$flag = $_POST['flag'];
$weekDay = $_POST['weekDay'];

#曜日取得
if($weekDay == '')$weekDay = getWeekday();

#時間取得
if(date(Hi) >= '0000' and date(Hi) < '0859'){
	$now = '';
	$next = 't1';
}else if(date(Hi) >= '0900' and date(Hi) < '0945'){
	$now = 't1';
	$next = 't2';
}else if(date(Hi) >= '0945' and date(Hi) < '1030'){
	$now = 't2';
	$next = 't3';
}else if(date(Hi) >= '1030' and date(Hi) < '1040'){
	$now = '';
	$next = 't3';
}else if(date(Hi) >= '1040' and date(Hi) < '1125'){
	$now = 't3';
	$next = 't4';
}else if(date(Hi) >= '1125' and date(Hi) < '1210'){
	$now = 't4';
	$next = 't5';
}else if(date(Hi) >= '1210' and date(Hi) < '1030'){
	$now = '';
	$next = 't5';
}else if(date(Hi) >= '1300' and date(Hi) < '1345'){
	$now = 't5';
	$next = 't6';
}else if(date(Hi) >= '1345' and date(Hi) < '1430'){
	$now = 't6';
	$next = 't7';
}else if(date(Hi) >= '1430' and date(Hi) < '1440'){
	$now = '';
	$next = 't7';
}else if(date(Hi) >= '1440' and date(Hi) < '1525'){
	$now = 't7';
	$next = 't8';
}else if(date(Hi) >= '1525' and date(Hi) <= '1610'){
	$now = 't8';
	$next = '';
}else{
	$now = '';
	$next = '';
}

#メアド、パスワード判定
#if(preg_match('/\A(?=.*?[a-z])(?=.*?\d)[a-z\d]{8,30}+\z/i',$password)){}
#else die('パスワードは半角英数字各１文字以上を含む８桁で入力してください');

#DB接続
require_once 'db.php';
$db = new db();

switch($flag){
	case 'login':
	#ログイン
		if(!$result = $db->login($email,$password))$result = 'アカウントが存在しません';
		break;
	case 'kill':
	#削除
		if(($db->kill($email,$password)) == true)$result = 'アカウントを削除しました';
		else $result = 'アカウントの削除に失敗しました';
		break;
	case 'register':
		#トークン生成
		if($token = $db->token()){
			#新規登録
			if($db->register($email,$password,$token,$groupName,date("YmdHi")) == true){
				$result = "登録が完了しました\n";
				#メールアドレス認証を追記
				#if($rtn = sendMail($email,$token))$result .= '送信されたメールを確認してください';
				#else $result .= "確認メールを送信できませんでした\n再度仮登録を行ってください";
			}else $result = "登録できませんでした\n登録済みの可能性があります";
		}else $result = '登録できませんでした';
		break;
	case 'session':
	#トークン確認（セッション維持）
		$token = $_POST['token'];
		$result = $db->session($token);
		break;
	case 'groupName':
	#グループ名取得
		if(!$result = $db->groupName())$result = 'グループはありません';
		break;
	case 'wSchedule':
	#スケジュール書き込み
		$t = $_POST['t'];
		$sql = insertSql('INSERT INTO (groupName,t1,t2,t3,t4,t5,t6,t7,t8) VALUES(?,?,?,?,?,?,?,?,?)',$weekDay,12);
		$updateSql = insertSql('UPDATE  SET t1 = ?, t2 = ?, t3 = ?, t4 = ?, t5 = ?, t6 = ?, t7 = ?, t8 = ? WHERE groupName = ?',$weekDay,7);
		if(($db->wSchedule($groupName,$t,$sql,$updateSql)) == true)$result = '更新完了';
		else $result = '更新失敗';
		break;
	case 'rSchedule':
	#スケジュール読み込み
		$sql = insertSql('SELECT t1,t2,t3,t4,t5,t6,t7,t8 FROM  WHERE groupName = ?',$weekDay,36);
		if(!$result = $db->rSchedule($groupName,$sql))$result = ",,,,,,,";
		break;
	case 'wBulletin':
	#掲示板書き込み
		$text = $_POST['text'];
		if(($db->wBulletin($groupName,$text)) == true)$result = '更新完了';
		else $result = '更新失敗';
		break;
	case 'rBulletin':
	#掲示板読み込み
		if(!$result = $db->rBulletin($groupName))$result = '掲示物はありません';
		break;
	case 'nowSub':
	#今の科目
		$rtn = dateJudg($weekDay);
		if($rtn){
			if($now == '')$result = '授業なし';
			else{
				$sql = createSql($now,$weekDay);
				if(!$result = $db->nowSub($groupName,$sql))$result = '時間割がありません';
			}
		}else $result = '今日は休日です';
		break;
	case 'nextSub':
	#次の科目
		$rtn = dateJudg($weekDay);
		if($rtn){
			if($next == '')$result = '授業なし';
			else{
				$sql = createSql($next,$weekDay);
				if(!$result = $db->nextSub($groupName,$sql))$result = '時間割がありません';
			}
		}else $result = '今日は休日です';
		break;
}
echo $result;

function createSql($time,$weekDay){
	if($weekDay == 'mon'){
		switch($time){
			case 't1':
				$sql = 'SELECT t1 FROM mon WHERE groupName = ?';
				break;
			case 't2':
				$sql = 'SELECT t2 FROM mon WHERE groupName = ?';
				break;
			case 't3':
				$sql = 'SELECT t3 FROM mon WHERE groupName = ?';
				break;
			case 't4':
				$sql = 'SELECT t4 FROM mon WHERE groupName = ?';
				break;
			case 't5':
				$sql = 'SELECT t5 FROM mon WHERE groupName = ?';
				break;
			case 't6':
				$sql = 'SELECT t6 FROM mon WHERE groupName = ?';
				break;
			case 't7':
				$sql = 'SELECT t7 FROM mon WHERE groupName = ?';
				break;
			case 't8':
				$sql = 'SELECT t8 FROM mon WHERE groupName = ?';
				break;
		}
	}elseif($weekDay == 'tue'){
		switch($time){
			case 't1':
				$sql = 'SELECT t1 FROM tue WHERE groupName = ?';
				break;
			case 't2':
				$sql = 'SELECT t2 FROM tue WHERE groupName = ?';
				break;
			case 't3':
				$sql = 'SELECT t3 FROM tue WHERE groupName = ?';
				break;
			case 't4':
				$sql = 'SELECT t4 FROM tue WHERE groupName = ?';
				break;
			case 't5':
				$sql = 'SELECT t5 FROM tue WHERE groupName = ?';
				break;
			case 't6':
				$sql = 'SELECT t6 FROM tue WHERE groupName = ?';
				break;
			case 't7':
				$sql = 'SELECT t7 FROM tue WHERE groupName = ?';
				break;
			case 't8':
				$sql = 'SELECT t8 FROM tue WHERE groupName = ?';
				break;
		}
	}elseif($weekDay == 'wed'){
		switch($time){
			case 't1':
				$sql = 'SELECT t1 FROM wed WHERE groupName = ?';
				break;
			case 't2':
				$sql = 'SELECT t2 FROM wed WHERE groupName = ?';
				break;
			case 't3':
				$sql = 'SELECT t3 FROM wed WHERE groupName = ?';
				break;
			case 't4':
				$sql = 'SELECT t4 FROM wed WHERE groupName = ?';
				break;
			case 't5':
				$sql = 'SELECT t5 FROM wed WHERE groupName = ?';
				break;
			case 't6':
				$sql = 'SELECT t6 FROM wed WHERE groupName = ?';
				break;
			case 't7':
				$sql = 'SELECT t7 FROM wed WHERE groupName = ?';
				break;
			case 't8':
				$sql = 'SELECT t8 FROM wed WHERE groupName = ?';
				break;
		}
	}elseif($weekDay == 'thu'){
		switch($time){
			case 't1':
				$sql = 'SELECT t1 FROM thu WHERE groupName = ?';
				break;
			case 't2':
				$sql = 'SELECT t2 FROM thu WHERE groupName = ?';
				break;
			case 't3':
				$sql = 'SELECT t3 FROM thu WHERE groupName = ?';
				break;
			case 't4':
				$sql = 'SELECT t4 FROM thu WHERE groupName = ?';
				break;
			case 't5':
				$sql = 'SELECT t5 FROM thu WHERE groupName = ?';
				break;
			case 't6':
				$sql = 'SELECT t6 FROM thu WHERE groupName = ?';
				break;
			case 't7':
				$sql = 'SELECT t7 FROM thu WHERE groupName = ?';
				break;
			case 't8':
				$sql = 'SELECT t8 FROM thu WHERE groupName = ?';
				break;
		}
	}elseif($weekDay == 'fri'){
		switch($time){
			case 't1':
				$sql = 'SELECT t1 FROM fri WHERE groupName = ?';
				break;
			case 't2':
				$sql = 'SELECT t2 FROM fri WHERE groupName = ?';
				break;
			case 't3':
				$sql = 'SELECT t3 FROM fri WHERE groupName = ?';
				break;
			case 't4':
				$sql = 'SELECT t4 FROM fri WHERE groupName = ?';
				break;
			case 't5':
				$sql = 'SELECT t5 FROM fri WHERE groupName = ?';
				break;
			case 't6':
				$sql = 'SELECT t6 FROM fri WHERE groupName = ?';
				break;
			case 't7':
				$sql = 'SELECT t7 FROM fri WHERE groupName = ?';
				break;
			case 't8':
				$sql = 'SELECT t8 FROM fri WHERE groupName = ?';
				break;
		}
	}
	return $sql;
}

function sendMail($email,$token){
	$serverPath = "kudkun.com/schedule/auth.php";
	$param = $serverPath.'?token='.$token;

	$name = '日程把握';
	$fromMail = '';
	$returnMail = '';
	$header = 'From: ' . mb_encode_mimeheader($name). ' <' . $fromMail. '>';
	$body = "下記URLからメールアドレスの認証を完了してください\n";
	$body = mb_convert_encoding($body,'UTF-8');
	$body .= $param;
	$subject = 'メールアドレス認証';
	$subject = mb_convert_encoding($subject,'UTF-8');
	if(mb_send_mail($email,$subject,$body,$header,$returnMail))return true;
	else return false;
}

function getWeekday(){
	$w = date("w");
	$weekList = array('','mon','tue','wed','thu','fri','');
	return $weekList[$w];
}

function dateJudg($weekDay){
	return ($weekDay != '') ? true : false;
}

function insertSql($text,$position,$num){
	return substr_replace($text,$position,$num,0);
}
