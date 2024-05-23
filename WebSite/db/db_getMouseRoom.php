<?php
$db = "grupo12_bd";
$dbhost = "127.0.0.1";
$username = $_POST["username"];
$password = $_POST["password"];
// $username = "root";
// $password = "";
$conn = mysqli_connect($dbhost, $username, $password, $db);

$sql = "SELECT IDExperiencia FROM v_expadecorrer LIMIT 1";

$result = mysqli_query($conn, $sql);

$r = mysqli_fetch_assoc($result);

$id = $r["IDExperiencia"];

$sql = "SELECT Sala, NúmeroRatosFinal FROM medicoessala WHERE IDExperiencia = $id ORDER BY Sala ASC";

$result = mysqli_query($conn, $sql);

$response["readings"] = array();
if (mysqli_num_rows($result) > 0) {
  while ($r = mysqli_fetch_assoc($result)) {
    $ad = array();
    // Alterar nome dos campos se necessario
    $ad["Room"] = $r["Sala"];
    $ad["TotalMouse"] = $r["NúmeroRatosFinal"];
    array_push($response["readings"], $ad);
  }
}


mysqli_close($conn);
header('Content-Type: application/json');
// tell browser that its a json data
echo json_encode($response);
// converting array to JSON string
