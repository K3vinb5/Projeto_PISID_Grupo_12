<?php
include 'logout.php';
?>

<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" type="text/css" href="../style.css">
    <title>Login</title>
</head>
<body class="index-body">
    <?php

    ?>
    <h1>Login to DashBoard</h1>
    <form class="index-form" action="login.php" method="post">
        <label for="username">Username</label><br>
        <input type="text" id="username" name="username" required>

        <label for="password">Password</label><br>
        <input type="password" id="password" name="password" required><br>

        <button type="submit">Login</button>
    </form>
</body>
</html>
