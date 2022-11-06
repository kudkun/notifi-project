<?php
class db{
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

	#ログイン
	function login($email,$before_hash_pass){
		$email = $this->mysql->real_escape_string($email);
		$sql = 'SELECT password,token,groupName FROM users WHERE email = ?';
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('s',$email);
		$stmt->execute();
		$stmt->bind_result($password,$token,$groupName);
		if($stmt->fetch() === true){
			$stmt->close();
			#パスワード比較→トークン返却
			if(password_verify($before_hash_pass,$password))return $token."\n".$groupName;
		}else $stmt->close();
	}

	#アカウント削除
	function kill($email,$before_hash_pass){
		$email = $this->mysql->real_escape_string($email);
		$sql = 'SELECT password FROM users WHERE email = ?';
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('s',$email);
		$stmt->execute();
		$stmt->bind_result($password);
		if($stmt->fetch() === true){
			$stmt->close();
			#パスワード比較→レコード削除
			if(password_verify($before_hash_pass,$password)){
				#削除するレコードのグループ名取得
				$sql = 'SELECT groupName FROM users WHERE email = ?';
				$stmt = $this->mysql->prepare($sql);
				$stmt->bind_param('s',$email);
				$stmt->execute();
				$stmt->bind_result($groupName);
				if($stmt->fetch() === true){
					$stmt->close();

					#削除対象のグループ名があるテーブルのレコードを全消去
					$sql = 'DELETE FROM	bulletin WHERE groupName = ?';
					$stmt = $this->mysql->prepare($sql);
					$stmt->bind_param('s',$groupName);
					$stmt->execute();
					$stmt->store_result();
					$stmt->close();

					$sql = 'DELETE FROM	mon WHERE groupName = ?';
					$stmt = $this->mysql->prepare($sql);
					$stmt->bind_param('s',$groupName);
					$stmt->execute();
					$stmt->store_result();
					$stmt->close();

					$sql = 'DELETE FROM	tue WHERE groupName = ?';
					$stmt = $this->mysql->prepare($sql);
					$stmt->bind_param('s',$groupName);
					$stmt->execute();
					$stmt->store_result();
					$stmt->close();

					$sql = 'DELETE FROM	wed WHERE groupName = ?';
					$stmt = $this->mysql->prepare($sql);
					$stmt->bind_param('s',$groupName);
					$stmt->execute();
					$stmt->store_result();
					$stmt->close();

					$sql = 'DELETE FROM	thu WHERE groupName = ?';
					$stmt = $this->mysql->prepare($sql);
					$stmt->bind_param('s',$groupName);
					$stmt->execute();
					$stmt->store_result();
					$stmt->close();

					$sql = 'DELETE FROM	fri WHERE groupName = ?';
					$stmt = $this->mysql->prepare($sql);
					$stmt->bind_param('s',$groupName);
					$stmt->execute();
					$stmt->store_result();
					$stmt->close();

					#※既存のレコード削除処理
					$sql = 'DELETE FROM users WHERE email = ?';
					$stmt = $this->mysql->prepare($sql);
					$stmt->bind_param('s',$email);
					$stmt->execute();
					$stmt->store_result();
					if(($res = $stmt->affected_rows) === 1){
						$stmt->close();
						return true;
					}else $stmt->close();
				}else $stmt->close();#
			}
		}else $stmt->close();
	}

	#ユーザ追加
	function register($email,$before_hash_pass,$token,$groupName,$date){
		$email = $this->mysql->real_escape_string($email);
		$groupName = $this->mysql->real_escape_string($groupName);
		$before_hash_pass = $this->mysql->real_escape_string($before_hash_pass);
		$hash_pass = password_hash($before_hash_pass,PASSWORD_BCRYPT,['cost' => 12]);
		$sql = 'INSERT INTO users(email,password,token,groupName,date) VALUES(?,?,?,?,?)';
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('ssssi',$email,$hash_pass,$token,$groupName,$date);
		$stmt->execute();
		$stmt->store_result();
		if(($res = $stmt->affected_rows) === 1){
			$stmt->close();
			return true;
		}else $stmt->close();
	}

	#トークン生成(40バイト)
	function token(){
		#$length = 16;#16*2=32
		#$token = openssl_random_pseudo_bytes($length);
		#return bin2hex($token);
		return sha1(uniqid(mt_rand(),true));
	}

	#トークン確認→トークンを返す
	function session($token){
		$sql = 'SELECT token FROM users WHERE token = ?';
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('s',$token);
		$stmt->execute();
		$stmt->bind_result($token);
		if($stmt->fetch() === true){
			$stmt->close();
			return $token;
		}else $stmt->close();
	}

	#グループ名取得
	function groupName(){
		$sql = 'SELECT groupName FROM users';
		if($stmt = $this->mysql->query($sql)){ 
			while($row = $stmt->fetch_assoc()){
				if($rows === null)$rows = $row['groupName'];
				else $rows .= "\n".$row['groupName'];
			}
			$stmt->close();
			return $rows;
		}
	}

	#スケジュール書き込み、更新
	function wSchedule($groupName,$t,$sql,$updateSql){
		$groupName = $this->mysql->real_escape_string($groupName);
		$t = $this->mysql->real_escape_string($t);
		$t = explode(',',$t);
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('sssssssss',$groupName,$t[0],$t[1],$t[2],$t[3],$t[4],$t[5],$t[6],$t[7]);
		$stmt->execute();
		$stmt->store_result();
		if(($res = $stmt->affected_rows) === 1){
			$stmt->close();
			return true;
		}else{
			$stmt->close();
			$stmt = $this->mysql->prepare($updateSql);
			$stmt->bind_param('sssssssss',$t[0],$t[1],$t[2],$t[3],$t[4],$t[5],$t[6],$t[7],$groupName);
			$stmt->execute();
			$stmt->store_result();
			if(($res = $stmt->affected_rows) === 1){
				$stmt->close();
				return true;
			}else $stmt->close();
		}
	}

	#スケジュール読み込み
	function rSchedule($groupName,$sql){
		$groupName = $this->mysql->real_escape_string($groupName);
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('s',$groupName);
		$stmt->execute();
		$stmt->bind_result($t1,$t2,$t3,$t4,$t5,$t6,$t7,$t8);
		if($stmt->fetch() === true){
			$stmt->close();
			$t = $t1.','.$t2.','.$t3.','.$t4.','.$t5.','.$t6.','.$t7.','.$t8;
			return $t;
		}else $stmt->close();
	}

	#今の授業
	function nowSub($groupName,$sql){
		$groupName = $this->mysql->real_escape_string($groupName);
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('s',$groupName);
		$stmt->execute();
		$stmt->bind_result($now);
		if($stmt->fetch() === true){
			$stmt->close();
			return $now;
		}else $stmt->close();
	}
	
	#今の授業
	function nextSub($groupName,$sql){
		$groupName = $this->mysql->real_escape_string($groupName);
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('s',$groupName);
		$stmt->execute();
		$stmt->bind_result($next);
		if($stmt->fetch() === true){
			$stmt->close();
			return $next;
		}else $stmt->close();
	}
	
	#掲示板更新
	function wBulletin($groupName,$text){
		$groupName = $this->mysql->real_escape_string($groupName);
		$text = $this->mysql->real_escape_string($text);
		$sql = 'INSERT INTO bulletin(groupName,text) VALUES(?,?)';
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('ss',$groupName,$text);
		$stmt->execute();
		$stmt->store_result();
		if(($res = $stmt->affected_rows) === 1){
			$stmt->close();
			return true;
		}else{
			$stmt->close();
			$sql = 'UPDATE bulletin SET text = ? WHERE groupName = ?';
			$stmt = $this->mysql->prepare($sql);
			$stmt->bind_param('ss',$text,$groupName);
			$stmt->execute();
			$stmt->store_result();
			if(($res = $stmt->affected_rows) === 1){
				$stmt->close();
				return true;
			}else $stmt->close();
		}
	}

	#掲示板取得
	function rBulletin($groupName){
		$groupName = $this->mysql->real_escape_string($groupName);
		$sql = 'SELECT text FROM bulletin WHERE groupName = ?';
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('s',$groupName);
		$stmt->execute();
		$stmt->bind_result($text);
		if($stmt->fetch() === true){
			$stmt->close();
			return $text;
		}else $stmt->close();
	}

    #テスト用
	function aauth($token){
		$sql = 'SELECT token FROM users WHERE token = ?';
		$stmt = $this->mysql->prepare($sql);
		$stmt->bind_param('s',$token);
		$stmt->execute();
		$stmt->bind_result($token);
		if($stmt->fetch() === true){
			$stmt->close();
			$sql = 'UPDATE users SET auth = ? WHERE token = ?';
			$stmt = $this->mysql->prepare($sql);
			$true = 1;
			$stmt->bind_param('is',$true,$token);
			$stmt->execute();
			$stmt->store_result();
			if(($res = $stmt->affected_rows) === 1){
				$stmt->close();
				return true;
			}else $stmt->close();
		}else $stmt->close();
	}

	#メールアドレス認証
	function auth($token){
		$sql = 'UPDATE users SET auth = ? WHERE token = ?';
		$stmt = $this->mysql->prepare($sql);
		$true = 1;
		$stmt->bind_param('is',$true,$token);
		$stmt->execute();
		$stmt->store_result();
		if(($res = $stmt->affected_rows) === 1){
			$stmt->close();
			return true;
		}else $stmt->close();
	}
}
