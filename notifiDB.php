<?php
class notifiDB{
	private $mysql;
	function __construct(){
		#DB情報
		require_once 'config.php';

		#DBに接続
		$this->mysql = new mysqli(HOST,USERNAME,PASSWORD,DBNAME);
		if($this->mysql->connect_errno){
			$result = 'データベースへ接続できません';
			die($result);
		}else $this->mysql->set_charset('UTF8');
	}

	function __destruct(){
		#DB切断
		$this->mysql->close();
	}

	#送信者名に該当するレコードがあり、送信者IDが自分ではなく、登録するレコードが既存ではない場合、受信者テーブルにレコード登録
	function addUser($text,$user,$date){
		$sql = 'SELECT name FROM notifiAdmin WHERE name = ?';
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('s',$text);
		$stmt->execute();
		$stmt->bind_result($name);
		if($stmt->fetch() === true){
			$stmt->close();

			#$sql = 'SELECT id FROM notifiAdmin WHERE id = ?';
			#$stmt = $this->mysql->prepare($sql);
			#$stmt->bind_param('s',$user);
			#$stmt->execute();
			#$stmt->bind_result($id);
			#if($stmt->fetch() !== true){
				#$stmt->close();
		
				$sql = 'SELECT name FROM notifiUser WHERE name = ? AND id = ?';
				$stmt = $this->mysql->prepare($sql);
				$stmt->bind_param('ss',$text,$user);
				$stmt->execute();
				$stmt->bind_result($name);
				if($stmt->fetch() !== true){
					$stmt->close();

					$sql = 'INSERT INTO notifiUser(name,id,date) VALUES(?,?,?)';
					$stmt = $this->mysql->prepare($sql);
					$stmt->bind_param('ssi',$text,$user,$date);
					$stmt->execute();
					if(($res = $stmt->affected_rows) === 1){
						$stmt->close();
						return true;
					}else $stmt->close();
				}else $stmt->close();
			#}else $stmt->close();
		}else $stmt->close();
	}

	#送信者登録
	function addAdmin($text,$token,$date){
		$sql = 'INSERT INTO notifiAdmin(name,token,date) VALUES(?,?,?)';
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('ssi',$text,$token,$date);
		$stmt->execute();
		if(($res = $stmt->affected_rows) === 1){
			$stmt->close();
			return true;
		}else $stmt->close();
	}

	#受信者削除
	function delUser($name,$user){
		$sql = 'DELETE FROM	notifiUser WHERE name = ? AND id = ?';
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('ss',$name,$user);
		$stmt->execute();
		if(($res = $stmt->affected_rows) === 1){
			$stmt->close();
			return true;
		}else $stmt->close();
	}

	#送信者削除
	function delAdmin($name,$token){
		$sql = 'DELETE FROM	notifiAdmin WHERE name = ? AND token = ?';
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('ss',$name,$token);
		$stmt->execute();
		if(($res = $stmt->affected_rows) === 1){
			$stmt->close();
			return true;
		}else $stmt->close();
	}

	#全受信者削除
	function delAllUser($text){
		$sql = 'DELETE FROM	notifiUser WHERE name = ?';
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('s',$text);
		$stmt->execute();
		if(($res = $stmt->affected_rows) === 1){
			$stmt->close();
			return true;
		}else $stmt->close();
	}

	#受信者によるトークン取得
	function getTokenByUser($text){
		$sql = 'SELECT token FROM notifiAdmin WHERE name = ?';
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('s',$text);
		$stmt->execute();
		$stmt->bind_result($token);
		$rows = '';
		while($stmt->fetch()){
			if($rows == '')$rows = $token;
			else $rows .= "\n".$token;
		}
		$stmt->close();
		return $rows;
	}

	#受信者取得
	function getUser($token){
		$sql = 'SELECT name FROM notifiAdmin WHERE token = ?';
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('s',$token);
		$stmt->execute();
		$stmt->bind_result($name);
		if($stmt->fetch() === true){
			$stmt->close();
			$sql = 'SELECT id FROM notifiUser WHERE name = ?';
			$stmt = $this->mysql->prepare($sql);
			$stmt->bind_param('s',$name);
			$stmt->execute();
			$stmt->bind_result($id);
			$rows = '';
			while($stmt->fetch()){
				if($rows == '')$rows = $id;
				else $rows .= "\n".$id;
			}
			$stmt->close();
			return $rows;
		}else $stmt->close();
	}

	#送信者確認
	function getAdmin($text){
		$sql = 'SELECT name FROM notifiAdmin WHERE name = ?';
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('s',$text);
		$stmt->execute();
		$stmt->bind_result($name);
		if($stmt->fetch() === true){
			$stmt->close();
			return true;
		}else $stmt->close();
	}
}
