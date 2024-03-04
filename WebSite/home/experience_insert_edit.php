<?php
session_start();
session_cache_limiter('Cache-Control : no-store, no-cache, must-revalidate, post-check=0, pre-check=0');

if (!isset($_SESSION['id'])) {
    // Redirect to the login page or display an error message
    header('Location: ../login/index.php');
    exit();
}
$type = $_GET['experience_type'];
$unique_id = $_GET['unique_id'];

echo $unique_id;
echo $_SESSION[$unique_id];
$row = $_SESSION[$unique_id];

if (isset( $_SESSION['1709350032'])) {
    echo "aaaa";
    echo $row["IDExperiência"];
}else{
    //echo "bbbbb";
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
    <title>Edit Experience</title>
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
    <br>
    <h2>Adicionar / Editar Experiência</h2>
    <div class="new-experience">
        <form action="../db/db_addExperience.php" method="post">
            <label for="desc">Descrição Experiência</label>
            <input type="text" id="desc" name="desc" required value="<?php echo $row["NúmeroRatos"];?>"><br>

            <label for="num_rats">Número Ratos</label>
            <input type="number" id="num_rats" name="num_rats" required value="<?php echo ""?>"><br>

            <label for="limit_rats">Limite Ratos</label>
            <input type="number" id="limit_rats" name="limit_rats" required value="<?php echo ""?>"><br>

            <label for="no_movement_time">Segundos sem Movimentos</label>
            <input type="number" id="no_movement_time" name="no_movement_time" required value="<?php echo ""?>"><br>

            <label for="ideal_temp">Temperatura Ideal</label>
            <input type="number" id="ideal_temp" name="ideal_temp" required value="<?php echo ""?>"><br>

            <label for="max_temp_change">Variação Temperatura Máxima</label>
            <input type="text" id="max_temp_change" name="max_temp_change" required value="<?php echo ""?>"><br>

            <label for="allowed_temp">Tolerância Temperatura</label>
            <input type="number" id="allowed_temp" name="allowed_temp" required value="<?php echo ""?>"><br>

            <button type="submit">Criar Experiência</button>

            <form>
    </div>
</div>

</body>
</html>