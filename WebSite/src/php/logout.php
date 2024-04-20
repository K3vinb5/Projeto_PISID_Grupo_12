<?php
session_start();
session_destroy();
session_unset();
$_SESSION = [];
header("Location: ../views/login.php");
exit();
?>