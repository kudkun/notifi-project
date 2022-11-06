<?php
#認証メールからデータ受信
$token = $_POST['token'];

#DB接続
require_once 'db.php';
$db = new db();

#仮登録レコードのトークンと一致すれば本登録
if($db->auth($token))$result = '本登録が完了しました';
else $result = "登録できませんでした\n再度認証を行ってください";

echo $result;
