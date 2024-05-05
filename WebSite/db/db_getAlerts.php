<?php

//password and username are received through the post request in its body
//bd value is hardcoded

$url = "127.0.0.1";
$database = "grupo12_bd";
$username = $_POST['username'];
$password = $_POST['password'];

try {
    $conn = mysqli_connect($url, $username, $password, $database);

    if (!$conn){
        $return = array(
            "success" => false,
        );

    }else{
        $return = array(
            "success" => true,
        );
    }
    echo json_encode($return);

}   catch (Exception $e){
    $return = array(
        "success" => false,
    );
    echo json_encode($return);
}