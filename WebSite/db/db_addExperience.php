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

$desc = validate($_POST['desc']);
$num_rats = validate($_POST['num_rats']);
$limit_rats = validate($_POST['limit_rats']);
$no_movement_time = validate($_POST['no_movement_time']);
$min_temp = floatval(validate($_POST['min_temp']));
$max_temp = floatval(validate($_POST['max_temp']));
$min_temp_alert = floatval(validate($_POST['min_temp_alert']));
$max_temp_alert = floatval(validate($_POST['max_temp_alert']));
$email = $_SESSION['email'];
$investigador = (isset($_POST['investigador']) && !empty($_POST['investigador'])) ? $_POST['investigador'] : $email;

$sql = "CALL InserirExperiencia(\"$desc\", $num_rats, $limit_rats, $no_movement_time, $min_temp, $max_temp, $max_temp_alert, $min_temp_alert,  \"$investigador\")";
mysqli_query($conn, $sql);
echo "$sql";

//redirects to experiences.php
header("Location: ../home/experiences.php");
$conn->close();
exit();
