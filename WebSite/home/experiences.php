<?php
session_start();

if (!isset($_SESSION['id'])) {
    // Redirect to the login page or display an error message
    header('Location: ../login/index.php');
    exit();
}
/**
 * @param mysqli $conn mysql connection
 * @param string $sql sql query
 * @return void html table from the databse table
 */
function table(mysqli $conn, string $sql)
{
    global $num;
    $result = mysqli_query($conn, $sql);
    if ($result->num_rows > 0) {
        echo "<table>\n<tr><th>ID</th><th>Investigador</th><th>Número Ratos</th><th>Limite Ratos</th><th>Limite Segundos</th><th>Temperatura Ideal</th><th>Variação Temperatura</th><th>Tolerância Temperatura</th><th>Início</th><th>Fim</th></tr>\n";

        // Output data of each row
        $index = 0;
        while ($row = $result->fetch_assoc()) {
            echo "<tr><td>" . $row["IDExperiência"] . "</td><td>" . $row["Investigador"] . "</td><td>" . $row["NúmeroRatos"] . "</td><td>" . $row["LimiteRatosSala"] . "</td><td>" . $row["SegundosSemMovimento"] . "</td><td>" . $row["TemperaturaIdeal"] . "</td><td>" . $row["VariaçãoTemperaturaMáxima"] . "</td><td>" . $row["TolerânciaTemperatura"] . "</td><td>" . $row["DataHoraInicioExperiência"] . "</td><td>" . $row["DataHoraFimExperiência"] . "</td><td><a href='experience_insert_edit.php?unique_id=" . $num . "&experience_type=edit'><button>Editar</button></a></td></tr>\n";
            $index ++;
            //TODO save $row elements in CurrentglobalNum_NAME
        }

        echo "</table>\n";
    } else {
        echo "<table border='1'><tr><th>ID</th><th>Numero Ratos</th><th>Inicio</th><th>Fim</th></tr></table>";
    }
}

?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" type="text/css" href="../style.css">
    <script type="text/javascript" src="../main.js"></script>
    <title>Experiencias</title>
</head>
<body>
    <nav>
        <div class="main-nav-container">
            <a href="home.php">Home</a>
            <a href="experiences.php">Experiencias</a>
        </div>
        <div class="logout-container">
            <a href="../login/index.php">Log Out</a>
        </div>
    </nav><br>
    <div>
        <h2 style="margin: 20px">Minhas Experiências</h2>
        <?php
        $num = 0;
        $url = "127.0.0.1";
        $database = "grupo12_bd";
        $username = "root";
        $password = "";
        $conn = mysqli_connect($url, $username, $password, $database);

        $id = $_SESSION['id'];

        $sql = "SELECT * FROM experiência WHERE Investigador='$id'";
        table($conn, $sql);
        ?>
        <form method="post" action="experience_insert_edit.php?unique_id=-1&experience_type=create">
            <button type="submit">Adicionar Nova experiência</button>
        </form>
        <br>
    </div>
<div id="add-experience">
    <h2 style="margin: 10px">Todas as Experiências</h2><br>
    <?php
    $sql = "SELECT * FROM experiência";

    table($conn, $sql);

    $conn->close();
    ?>
</div>
</body>
</html>
