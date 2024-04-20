<?php
// TODO : SESSION CACHE LIMITER
// session_cache_limiter('Cache-Control : no-store, no-cache, must-revalidate, post-check=0, pre-check=0'); 
require('utils.php');
session_start();

$user = new User();
try {
    $user->ligarBD(User::validate($_POST['username']), User::validate($_POST['password']));
} catch(Exception $e) {
    $_SESSION['wrong_user_pass'] = true;
    header("Location: ../views/login.php");
    exit();
}

$_SESSION["user"] = $user;
header("Location: ../views/home.php"); 
exit();

    //     $_SESSION['username'] = $row['NomeUtilizador'];
    //     $_SESSION['usertype'] = $row['TipoUtilizador'];
    //    $_SESSION['id'] = $row['IDUtilizador'];
?>
