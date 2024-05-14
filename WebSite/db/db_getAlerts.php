<?php
$dbhost = "127.0.0.1";
$db = "grupo12_bd"; //database name
$username = $_POST["username"];
$password = $_POST["password"];
$time = $_POST["time"];

$username = "root";
$password = "";
$time = "3600";

$conn = mysqli_connect($dbhost, $username, $password, $db);

$sql = "SELECT * FROM alerta WHERE DataHora >= NOW() - INTERVAL $time SECOND ORDER BY DataHora DESC";

$result = mysqli_query($conn, $sql);

$response["alerts"] = array();


if (mysqli_num_rows($result) > 0) {
    while ($r = mysqli_fetch_assoc($result)) {
        try {
            $ad = array();
            $ad["Hora"] = $r['DataHora'];
            $ad["Sala"] = $r['Sala'];
            $ad["Sensor"] = $r['Sensor'];
            $ad["Leitura"] = $r['Leitura'];
            $ad["TipoAlerta"] = $r['TipoAlerta'];
            $ad["Mensagem"] = $r['Mensagem'];
            array_push($response["alerts"], $ad);
        } catch (Exception $e) {
            echo($e);
        }
    }
}

// header('Content-Type: application/json');
// tell browser that its a json data
echo json_encode($response);
//converting array to JSON string
?>
