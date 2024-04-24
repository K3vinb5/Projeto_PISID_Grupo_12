<?php
class User {
    var $conn;
    var $url = "127.0.0.1";
    var $database = "grupo12_bd";

    function ligarBD($username, $password) {
        $this->conn = mysqli_connect($this->url, $username, $password, $this->database);
        if (!$this->conn) {
            throw new Exception("Não conseguiu entrar");
        }
    }
    
    public static function validate($data){
        $data = trim($data);
        $data = stripslashes($data);
        $data = htmlspecialchars($data);
        return $data;
    }
}
?>