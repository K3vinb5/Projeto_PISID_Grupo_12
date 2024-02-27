<?php session_start();?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" type="text/css" href="style.css">
    <script type="text/javascript" src="main.js"></script>
    <title>Document</title>
</head>
<body>
    <?php
    $url = "127.0.0.1";
    $database = "grupo12_bd";
    $username = "root";
    $password = "";
    $conn = mysqli_connect($url, $username, $password, $database);
    //TODO
    /*if (!$conn) {
          echo "Connection failed!";
    }else{
        echo "<p>Success</p>";
    }*/

    function validate($data){
        $data = trim($data);
        $data = stripslashes($data);
        $data = htmlspecialchars($data);
        return $data;
    }

    $username = validate($_POST['username']);
    $password = validate($_POST['password']);

    $sql = "SELECT * FROM utilizador WHERE NomeUtilizador='$username' AND PasswordUtilizador='$password'";

    $result = mysqli_query($conn, $sql);
    //Success
    if (mysqli_num_rows($result) === 1) {
        $row = mysqli_fetch_assoc($result);
        if ($row['NomeUtilizador'] === $username && $row['PasswordUtilizador'] === $password) {

            $_SESSION['username'] = $row['NomeUtilizador'];
            $_SESSION['usertype'] = $row['TipoUtilizador'];
            $_SESSION['id'] = $row['IDUtilizador'];

            //redirects to home.php
            header("Location: home.php");
            $conn->close();
            exit();
        }else{
            echo "
            <h1>Error, username or password wrong</h1><br>
            <form action='index.php'>
                <button>Go back to login screen</button>
            <form>
            ";
        }
    }else{
        echo "
            <h1>Error, username or password wrong</h1><br>
            <form action='index.php'>
                <button>Go back to login screen</button>
            <form>
            ";
    }
    $conn->close();
    ?>
</body>
</html>
