<?php
session_start();
session_cache_limiter('Cache-Control : no-store, no-cache, must-revalidate, post-check=0, pre-check=0');

if (!isset($_SESSION['email'])) {
    // Redirect to the login page or display an error message
    header('Location: ../login/index.php');
    exit();
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
    <title>Home</title>
</head>
<body>
    <?php
    $username = $_SESSION['username'];
    ?>

    <nav>
        <div class="main-nav-container">
            <a href="home.php">Home</a>
            <a href="experiences.php">Experiencias</a>
        </div>
        <div class="logout-container">
            <a href="../login/index.php">Log Out</a>
        </div>
    </nav>

    <div>
        <h1>Painel de Controlo</h1>

        <p>Bem vindo de volta <?php echo $username ?> !</p>
    </div>

</body>
</html>