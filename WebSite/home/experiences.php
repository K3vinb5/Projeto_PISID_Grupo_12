<?php
session_start();

if (!isset($_SESSION['email'])) {
    // Redirect to the login page or display an error message
    header('Location: ../login/index.php');
    exit();
}
/**
 * @param mysqli $conn mysql connection
 * @param string $sql sql query
 * @return void html table from the databse table
 */
function table(mysqli $conn, string $sql, bool $mine)
{
    $result = mysqli_query($conn, $sql);
    if ($result->num_rows > 0) {
        echo "<table>\n<tr><th>Investigador</th><th>Número Ratos</th><th>Limite Ratos</th><th>Limite Segundos</th><th>Temperatura Minima</th><th>Temperatura Maxima</th><th>Temperatura Maxima Aviso</th><th>Temperatura Minima Aviso</th><th>Início</th><th>Fim</th></tr>\n";

        // Output data of each row
        $index = 0;
        $state = "";
        $buttonText = "Edit";
        while ($row = $result->fetch_assoc()) {
            if ($row["DataHoraInicioExperiência"] == "" && $row["DataHoraFimExperiência"] == "") {
                //Experience not started
                $state = "notStarted";
            } else if ($row["DataHoraInicioExperiência"] != "" && $row["DataHoraFimExperiência"] == "") {
                //Experience ongoing
                $state = "onGoing";
            } else {
                //Experience ended
                $state = "ended";
            }

            if (!$mine) {
                $buttonText = "Details";
            } else if ($state != "notStarted") {
                $buttonText = "Edit";
            }
            echo "<tr><td>" . $row["Investigador"] . "</td><td>" . $row["NúmeroRatos"] . "</td><td>" . $row["LimiteRatosSala"] . "</td><td>" . $row["SegundosSemMovimento"] . "</td><td>" . $row["TemperaturaMinima"] . "</td><td>" . $row["TemperaturaMaxima"] . "</td><td>" . $row["TemperaturaAvisoMaximo"] . "</td><td>" . $row["TemperaturaAvisoMinimo"] . "</td><td>" . $row["DataHoraInicioExperiência"] . "</td><td>" . $row["DataHoraFimExperiência"] . "</td><td><a href='experience_insert_edit.php?type=edit&id=" . $row["IDExperiencia"] . "&state=" . $state . "'><button>" . $buttonText . "</button></a></td></tr>\n";
            $index++;
        }

        echo "</table>\n";
    } else {
        echo "<table border='1'><tr><th>Numero Ratos</th><th>Inicio</th><th>Fim</th></tr></table>";
    }
}

?>
<!doctype html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" type="text/css" href="../style.css">
    <script type="text/javascript" src="../main.js"></script>
    <title>Experiencias</title>
</head>

<body>
    <nav>
        <div class="main-nav-container">
            <a href="experiences.php">Experiencias</a>
            <a href="experience_insert_edit.php?type=create">Adicionar Experiencia</a>
        </div>
        <div class="logout-container">
            <a href="../login/edit_user.php">Editar Utilizador</a>
            <a href="../login/index.php">Log Out</a>
        </div>
    </nav><br>
    <div>
        <h2 style="margin: 20px">Minhas Experiências</h2>
        <?php
        $url = "127.0.0.1";
        $database = "grupo12_bd";
        $username = $_SESSION['email'];
        $password = $_SESSION['password'];
        $conn = mysqli_connect($url, $username, $password, $database);

        $email = $_SESSION['email'];

        $sql = "SELECT * FROM experiencia WHERE Investigador='$email' ORDER BY DataHoraCriaçãoExperiência DESC";
        table($conn, $sql, true);
        ?>
        <br>
    </div>
    <div id="add-experience">
        <h2 style="margin: 10px">Todas as Experiências</h2><br>
        <?php
        $sql = "SELECT * FROM experiencia WHERE Investigador!='$email' ORDER BY DataHoraCriaçãoExperiência DESC";

        table($conn, $sql, false);

        $conn->close();
        ?>
    </div>
</body>

</html>