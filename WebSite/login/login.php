<?php
session_start();

?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" type="text/css" href="../style.css">
    <script type="text/javascript" src="../main.js"></script>
    <title>Document</title>
</head>
<body>
    <?php

    $url = "127.0.0.1";
    $database = "grupo12_bd";
    $username = $_POST['username'];
    $password = $_POST['password'];
    $conn = mysqli_connect($url, $username, $password, $database);
    //TODO
    if (!$conn){
        //Connection Failed
        echo "
            <h1>Error, username or password wrong</h1><br>
            <form action='index.php'>
                <button>Go back to login screen</button>
            <form>
            ";
    }else{
        $_SESSION['email'] = $username;
        $_SESSION['password'] = $password;
        $sql = "SELECT * FROM utilizador WHERE Email='$username'";
        $result = mysqli_query($conn, $sql);
        $row = mysqli_fetch_assoc($result);
        $_SESSION['username'] = $row['Nome'];
        //If user is removed logaclly
        if($row['RemocaoLogica'] == 1){
            echo "
            <h1>Error, username or password wrong</h1><br>
            <form action='index.php'>
                <button>Go back to login screen</button>
            <form>
            ";
        }else{
            header("Location: ../home/experiences.php");
            $conn->close();
            exit();
        }
    }
    $conn->close();
    ?>
</body>
</html>
