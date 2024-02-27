<?php
session_start();
function validate($data){
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data);
    return $data;
}

$url = "127.0.0.1";
$database = "grupo12_bd";
$username = "root";
$password = "";
$conn = mysqli_connect($url, $username, $password, $database);

$id = $_SESSION['id'];

$desc = validate($_POST['desc']);
$num_rats = validate($_POST['num_rats']);
$limit_rats = validate($_POST['limit_rats']);
$no_movement_time = validate($_POST['no_movement_time']);
$ideal_temp = validate($_POST['ideal_temp']);
$max_temp_change= validate($_POST['max_temp_change']);
$allowed_temp = validate($_POST['allowed_temp']);
$begin_experience = validate($_POST['begin_experience']);
$end_experience = validate($_POST['end_experience']);

$sql = "INSERT INTO `experiência` (`IDExperiência`, `Descrição`, `Investigador`, `DataHoraCriaçãoExperiência`, `NúmeroRatos`, `LimiteRatosSala`, `SegundosSemMovimento`, `TemperaturaIdeal`, `VariaçãoTemperaturaMáxima`, `TolerânciaTemperatura`, `DataHoraInicioExperiência`, `DataHoraFimExperiência`)
VALUES (NULL, '$desc', '$id', current_timestamp(), '$num_rats', '$limit_rats', '$no_movement_time', '$ideal_temp', '$max_temp_change', '$allowed_temp', '2024-02-12 03:02:12', '2024-02-13 03:02:12')";
echo "$sql";
mysqli_query($conn, $sql);
//redirects to experiences.php
header("Location: experiences.php");
$conn->close();
exit();