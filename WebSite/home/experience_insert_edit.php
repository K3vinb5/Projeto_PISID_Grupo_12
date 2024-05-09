<?php
session_start();

if (!isset($_SESSION['email'])) {
    // Redirect to the login page or display an error message
    header('Location: ../login/index.php');
    exit();
}
$type = $_GET['type'];
$state = isset($_GET['state']) ? $_GET['state'] : '';
$id = isset($_GET['id']) ? $_GET['id'] : '';

function isAdministrator()
{
    $url = "127.0.0.1";
    $database = "grupo12_bd";
    $username = $_SESSION['email'];
    $password = $_SESSION['password'];
    $conn = mysqli_connect($url, $username, $password, $database);

    $sql = "CALL ObterRoleUtilizador()";
    $stmt = $conn->prepare($sql);
    $stmt->execute();
    $result = $stmt->get_result();
    while ($row = $result->fetch_assoc()) {
        if ($row['Role'] == "AdministradorAplicacao") {
            return true;
        }
    }

    return false;
}

function table(mysqli $conn, string $sql)
{
    $result = mysqli_query($conn, $sql);
    if ($result->num_rows > 0) {
        echo "<table>\n<tr><th>Sala</th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th><th>9</th><th>10</th></tr>\n";

        echo "<tr><td style=\"font-weight: bold\">Ratos</td>";
        while ($row = $result->fetch_assoc()) {
            echo "<td>" . $row["NúmeroRatosFinal"] . "</td>";
        }
        echo "</tr>\n";
        echo "</table>\n";
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
    <title>Edit Experience</title>
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
    </nav>
    <br>
    <div>
        <br>
        <?php
        $descricao = "";
        $numRatos = 0;
        $limiteRatos = 0;
        $noMovement = 0;
        $minTemp = 0;
        $maxTemp = 0;
        $maxTempAlert = 0;
        $minTempAlert = 0;

        $edit = "../db/db_addExperience.php";

        if ($type == "create") {
            echo "<h2>Adicionar nova Experiência</h2>";
        } else {
            echo "<h2>Editar Experiência</h2>";

            $url = "127.0.0.1";
            $database = "grupo12_bd";
            $username = $_SESSION['email'];
            $password = $_SESSION['password'];
            $conn = mysqli_connect($url, $username, $password, $database);

            $email = $_SESSION['email'];

            $sql = "SELECT * FROM experiencia WHERE IDExperiencia='$id'";
            $result = mysqli_query($conn, $sql);
            $row = $result->fetch_assoc();

            $investigador = $row['Investigador'];
            $descricao = $row['Descrição'];
            $numRatos = $row['NúmeroRatos'];
            $limiteRatos = $row['LimiteRatosSala'];
            $noMovement = $row['SegundosSemMovimento'];
            $minTemp = $row['TemperaturaMinima'];
            $maxTemp = $row['TemperaturaMaxima'];
            $maxTempAlert = $row['TemperaturaAvisoMaximo'];
            $minTempAlert = $row['TemperaturaAvisoMinimo'];
        }
        ?>
        <div class="new-experience">
            <div class="form-experience">
                <form action="<?php
                                if ($type == "create") {
                                    echo "../db/db_addExperience.php";
                                } else {
                                    echo "../db/db_editExperience.php?id=" . $id;
                                }
                                ?>" method="post">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="desc">Descrição Experiência:</label>
                            <input <?php if ($type != "create") {
                                        if ($investigador != $email && !isAdministrator()) echo 'disabled';
                                    } ?> type="text" id="desc" name="desc" style="width: 95%" required value="<?php if ($type != "create") echo "$descricao" ?>">
                        </div>
                    </div>
                    <div class="form-row" style="<?php if (!isAdministrator()) {
                                                        echo "display: none;";
                                                    } ?>">
                        <div class="form-group">
                            <label for="investigador" style="margin-left: 10%">Email do Investigador:</label>
                            <input type="text" id="investigador" name="investigador" style="width: 80%; margin-left: 10%" value="<?php if ($type != "create") echo "$investigador" ?>">
                        </div>
                        <div class="form-group">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="num_rats" style="margin-left: 10%">Número Ratos:</label>
                            <input <?php if ($type != "create") {
                                        if ($investigador != $email && !isAdministrator()) echo 'disabled';
                                    } ?> type="number" id="num_rats" name="num_rats" style="width: 80%; margin-left: 10%" required value="<?php if ($type != "create") echo "$numRatos" ?>">
                        </div>
                        <div class="form-group">
                            <label for="limit_rats">Limite Ratos:</label>
                            <input <?php if ($type != "create") {
                                        if ($investigador != $email && !isAdministrator()) echo 'disabled';
                                    } ?> type="number" id="limit_rats" name="limit_rats" style="width: 80%" required value="<?php if ($type != "create") echo "$limiteRatos" ?>">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="no_movement_time" style="margin-left: 10%">Segundos sem Movimentos:</label>
                            <input <?php if ($type != "create") {
                                        if ($investigador != $email && !isAdministrator()) echo 'disabled';
                                    } ?> type="number" id="no_movement_time" name="no_movement_time" style="width: 80%;margin-left: 10%" required value="<?php if ($type != "create") echo "$noMovement" ?>">
                        </div>
                        <div class="form-group">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="min_temp" style="margin-left: 10%">Temperatura Mínima:</label>
                            <input <?php if ($type != "create") {
                                        if ($investigador != $email && !isAdministrator()) echo 'disabled';
                                    } ?> type="number" step="0.01" id="min_temp" name="min_temp" style="width: 80%; margin-left: 10%" required value="<?php if ($type != "create") echo "$minTemp" ?>">
                        </div>
                        <div class="form-group">
                            <label for="min_temp_alert">Temperatura Aviso Mínimo:</label>
                            <input <?php if ($type != "create") {
                                        if ($investigador != $email && !isAdministrator()) echo 'disabled';
                                    } ?> type="number" step="0.01" id="min_temp_alert" name="min_temp_alert" style="width: 80%" required value="<?php if ($type != "create") echo "$minTempAlert" ?>">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="max_temp" style="margin-left: 10%">Temperatura Máxima:</label>
                            <input <?php if ($type != "create") {
                                        if ($investigador != $email && !isAdministrator()) echo 'disabled';
                                    } ?> type="number" step="0.01" id="max_temp" name="max_temp" style="width: 80%; margin-left: 10%" required value="<?php if ($type != "create") echo "$maxTemp" ?>">
                        </div>
                        <div class="form-group">
                            <label for="max_temp_change">Temperatura Aviso Máxima:</label>
                            <input <?php if ($type != "create") {
                                        if ($investigador != $email && !isAdministrator()) echo 'disabled';
                                    } ?> type="number" step="0.01" id="max_temp_alert" name="max_temp_alert" style="width: 80%" required value="<?php if ($type != "create") echo "$maxTempAlert" ?>">
                        </div>
                    </div>
                    <br>
                    <br>
                    <button type='submit' style="float: right; <?php if ($investigador != $email && !isAdministrator()) {
                                                                    echo "display: none;";
                                                                } ?>">
                        <?php if ($type == "create") {
                            echo "Criar Experiência";
                        } else {
                            echo "Editar Experiência";
                        } ?>
                    </button>
                    <?php
                    if ($type != "create") {
                        if ($investigador == $email || isAdministrator()) {
                            if ($state == "notStarted") {
                                //not Started
                                echo "<button formaction=\"../db/db_startStopExperience.php?id=" . $id . "\" type='submit' style=\"float: right\">Começar Experiência</button>";
                            } else if ($state == "onGoing") {
                                //onGoing
                                echo "<button formaction=\"../db/db_startStopExperience.php?id=" . $id . "\" type='submit' style=\"float: right\">Terminar Experiência</button>";
                            } else {
                                //Ended
                                echo "<p>Esta experiência acabou</p>";
                            }
                        }
                    }
                    ?>
                </form>
            </div>
        </div>

        <div class="form-experience" style="<?php if ($type == "create") {
                                                echo "display: none;";
                                            } ?>">
            <div class="form-row">
                <div class="form-group">
                    <label for="desc">Número de ratos em cada sala:</label>
                    <?php
                    $url = "127.0.0.1";
                    $database = "grupo12_bd";
                    $username = $_SESSION['email'];
                    $password = $_SESSION['password'];
                    $conn = mysqli_connect($url, $username, $password, $database);

                    $sql = "CALL ObterRatosSalasExperiencia('$id')";
                    table($conn, $sql);
                    ?>
                </div>
            </div>
        </div>
        <br>
        <br>
        <br>
    </div>


</body>

</html>