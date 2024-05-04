<?php
session_start();
function validate($data)
{
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data);
    return $data;
}

$url = "127.0.0.1";
$database = "grupo12_bd";
$username = $_SESSION['email'];
$password = $_SESSION['password'];
$conn = mysqli_connect($url, $username, $password, $database);

$id = $_GET['id'];

$sql = "CALL ComecarTerminarExperienca($id)";
mysqli_query($conn, $sql);
echo "$sql";

//redirects to experiences.php
header("Location: ../home/experiences.php");
$conn->close();
exit();
