<?php
#jsonデータ取得
if(!$json_string = file_get_contents('php://input'))exit;
$json_object = json_decode($json_string);
$user = $json_object->{'events'}[0]->{'source'}->{'userId'};
$text = $json_object->{'events'}[0]->{'message'}->{'text'};
$replyToken = $json_object->{'events'}[0]->{'replyToken'};

#DB接続
require_once 'notifiDB.php';
$db = new notifiDB();

if($text == ''){#自作アプリからの通知
	#全アクセストークン取得
	$accessToken = array();
	if($accessToken = explode(',',receive_replace($_POST['token']))){
		$accessToken = array_map('trim',$accessToken);
		$accessToken = array_filter($accessToken,'strlen');
		$accessToken = array_values($accessToken);
		$text = $_POST['text'];
		$content = [
			'type' => 'text',
			'text' => $text
		];

		#通知
		push($content,$accessToken);
		echo "通知が完了しました";
	}
}else{#Lineアプリで受信
	#無効なアクセストークンを持つ管理者レコードを削除する処理を追加したい！！！！！
	#起句、グループ名、アクセストークン（送信者の場合）に分割
	$tmp = array();
	$tmp = explode("\n",$text);
	if($tmp[0] != '' && $tmp[1] != ''){
		$tmp[1] = preg_replace("/( |　)/","",$tmp[1]);
		$date = date('Y-m-d H:i:s');
		switch($tmp[0]){
			case 'add':
				if($tmp[2] != ''){
					#アクセストークンの検証
					$result = verify($tmp[2]);
					if($result == '{"message":"The request body has 1 error(s)","details":[{"message":"May not be empty","property":"to"}]}'){
						#送信者登録＆登録成功通知
						if($rtn = $db->addAdmin($tmp[1],$tmp[2],$date))reply("【登録完了】\nあなたのグループ名は「".$tmp[1]."」です\nアプリから通知ができます",$tmp[2],$replyToken);
					}
				}else{
					#受信者登録
					if($rtn = $db->addUser($tmp[1],$user,$date)){
						$result = $db->getTokenByUser($tmp[1]);
						$accessToken = explode("\n",$result);
						#参加完了通知
						$i = 0;
						while($accessToken[$i] != ''){
							reply("【参加完了】\n「".$tmp[1]."」のルームに参加しました\n通知を待ちましょう",$accessToken[$i],$replyToken);
							$i++;
						}
					}
				}
				break;
			case 'block':
				if($tmp[2] != ''){
						#送信者削除＆削除成功通知
						if($rtn = $db->delAdmin($tmp[1],$tmp[2]))reply("【退出完了】\n削除したトークンでのアプリ通知はできません",$tmp[2],$replyToken);
						if(!$result = $db->getAdmin($tmp[1])){
							if($result = $db->delAllUser($tmp[1]))reply("【削除完了】\n「".$tmp[1]."」グループの参加者を削除しました",$tmp[2],$replyToken);
						}
				}else{
					#受信者削除
					if($rtn = $db->delUser($tmp[1],$user)){
						$result = $db->getTokenByUser($tmp[1]);
						$accessToken = explode("\n",$result);
						#削除完了通知
						$i = 0;
						while($accessToken[$i] != ''){
							reply("【退出完了】\n「".$tmp[1]."」から通知を受け取れません",$accessToken[$i],$replyToken);
							$i++;
						}
					}
				}
				break;
		}
	}
}


#通知
function push($content,$accessToken){
	if($content != ''){
		for($i = 0;$i <= count($accessToken)-1;$i++){
			$url = 'https://api.line.me/v2/bot/message/push';
			$ch = curl_init();
			curl_setopt($ch,CURLOPT_URL,$url);
			curl_setopt($ch,CURLOPT_POST,true);
			curl_setopt($ch,CURLOPT_CUSTOMREQUEST,'POST');
			curl_setopt($ch,CURLOPT_RETURNTRANSFER,true);
			curl_setopt($ch,CURLOPT_HTTPHEADER,array(
				'Content-Type: application/json; charser=UTF-8',
				'Authorization: Bearer ' . $accessToken[$i]
			));

			#$accessToken[$i]トークンを持つ管理者グループの全参加者取得
			$result = $db->getUser($accessToken[$i]);
			$tmp = array();
			$tmp = explode("\n",$result);
			$j = 0;
			while($tmp[$j] != ''){
				#if(strpos($tmp[$j],$user) === false){
					$post_data = [
						'to' => $tmp[$j],
						'messages' => [$content]
					];
					curl_setopt($ch,CURLOPT_POSTFIELDS,json_encode($post_data));
					curl_exec($ch);
				#}
				$j++;
			}
			curl_close($ch);
		}
	}
}


#アクセストークン検証
function verify($text){
	$url = 'https://api.line.me/v2/bot/message/push';
	$ch = curl_init();
	curl_setopt($ch,CURLOPT_URL,$url);
	curl_setopt($ch,CURLOPT_POST,true);
	curl_setopt($ch,CURLOPT_CUSTOMREQUEST,'POST');
	curl_setopt($ch,CURLOPT_RETURNTRANSFER,true);
	curl_setopt($ch,CURLOPT_HTTPHEADER,array(
		'Content-Type: application/json; charser=UTF-8',
		'Authorization: Bearer ' . $text
	));
	$content = [
		'type' => 'text',
		'text' => 'verify'
	];
	$post_data = [
		'to' => '',
		'messages' => [$content]
	];
	curl_setopt($ch,CURLOPT_POSTFIELDS,json_encode($post_data));
	$result = curl_exec($ch);
	curl_close($ch);
	return $result;
}


#リプライ
function reply($text,$accessToken,$replyToken){
	$content = [
		'type' => 'text',
		'text' => $text
	];
	$post_data = [
		'replyToken' => $replyToken,
		'messages' => [$content]
	];

	$url = 'https://api.line.me/v2/bot/message/reply';
	$ch = curl_init();
	curl_setopt($ch,CURLOPT_URL,$url);
	curl_setopt($ch,CURLOPT_POST,true);
	curl_setopt($ch,CURLOPT_CUSTOMREQUEST,'POST');
	curl_setopt($ch,CURLOPT_RETURNTRANSFER,true);
	curl_setopt($ch,CURLOPT_HTTPHEADER,array(
		'Content-Type: application/json; charser=UTF-8',
		'Authorization: Bearer ' . $accessToken
	));
	curl_setopt($ch,CURLOPT_POSTFIELDS,json_encode($post_data));
	$result = curl_exec($ch);
	curl_close($ch);
}
