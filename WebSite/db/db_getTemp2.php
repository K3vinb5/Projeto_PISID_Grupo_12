<?php

//password and username are received through the post request in its body
//bd value is hardcoded

$url = "127.0.0.1";
$database = "grupo12_bd";
$username = $_POST['username'];
$password = $_POST['password'];
$time = $_POST['time'];

//$username = "root";
//$password = "";
//$time = 3;

$conn = mysqli_connect($url, $username, $password, $database);

$sql = "SELECT  mt.DataHora, mt.Leitura FROM medicoestemperatura mt, sensor s, tiposensor ts WHERE mt.Sensor = s.IDSensor AND s.IDTipoSensor = ts.IDTipoSensor AND s.Nome = '2' AND ts.Designacao = 'Temperatura' AND mt.DataHora >= NOW() - INTERVAL $time MINUTE;;";
$result = mysqli_query($conn, $sql);
$readings = "[";

$row_count = $result->num_rows;
$counter = 0;
while ($row = $result->fetch_assoc()) {
    $counter++;
    if ($counter == $row_count) {
        $readings .= json_encode($row)."]";
    }else{
        $readings .= json_encode($row).",";
    }
}

echo "{\"readings\": ".$readings."}";