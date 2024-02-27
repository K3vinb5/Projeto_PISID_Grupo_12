<?php session_start();?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" type="text/css" href="style.css">
    <script type="text/javascript" src="main.js"></script>
    <title>Experiencias</title>
</head>
<body>
    <nav>
        <div class="main-nav-container">
            <a href="home.php">Home</a>
            <a href="experiences.php">Experiencias</a>
        </div>
        <div class="logout-container">
            <a href="index.php">Log Out</a>
        </div>
    </nav><br>
    <div>
        <h2 style="margin: 20px">Experiências</h2>
        <?php
        $url = "127.0.0.1";
        $database = "grupo12_bd";
        $username = "root";
        $password = "";
        $conn = mysqli_connect($url, $username, $password, $database);

        $id = $_SESSION['id'];

        $sql = "SELECT * FROM experiência WHERE Investigador='$id'";
        $result = mysqli_query($conn, $sql);

        if ($result->num_rows > 0) {
            echo "<table>\n<tr><th>ID</th><th>Numero Ratos</th><th>Inicio</th><th>Fim</th></tr>\n";

            // Output data of each row
            while ($row = $result->fetch_assoc()) {
                echo "<tr><td>" . $row["IDExperiência"] . "</td><td>" . $row["NúmeroRatos"] . "</td><td>" . $row["DataHoraInicioExperiência"] . "</td><td>" . $row["DataHoraFimExperiência"] . "</td></tr>\n";
            }

            echo "</table>\n";
        }else{
            echo "<table border='1'><tr><th>ID</th><th>Numero Ratos</th><th>Inicio</th><th>Fim</th></tr></table>";
        }
        $conn->close();
        ?>
    </div>
<div id="add-experience">
    <h2 style="margin: 10px">Agendar novas Experiências</h2><br>
    <button onclick="addExperience()">Nova Experiência</button>
</div>
</body>
</html>
