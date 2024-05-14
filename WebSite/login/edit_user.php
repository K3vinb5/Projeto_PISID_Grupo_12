<?php
session_start();

if (!isset($_SESSION['email'])) {
    // Redirect to the login page or display an error message
    header('Location: ../login/index.php');
    exit();
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" type="text/css" href="../style.css">
    <script type="text/javascript" src="../main.js"></script>
    <title>Edit user</title>
</head>

<body>
    <nav>
        <div class="main-nav-container">
            <a href="../home/experiences.php">Experiencias</a>
            <a href="../home/experience_insert_edit.php?type=create">Adicionar Experiencia</a>
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
        $email = "";
        $nome = "";
        $telefone = "";

        $edit = "../db/db_editUser.php";

        echo "<h2>Editar utilizador</h2>";

        $url = "127.0.0.1";
        $database = "grupo12_bd";
        $email = $_SESSION['email'];
        $password = $_SESSION['password'];
        $conn = mysqli_connect($url, $email, $password, $database);

        $sql = "SELECT * FROM v_utilizador WHERE Email='$email'";
        $result = mysqli_query($conn, $sql);
        $row = $result->fetch_assoc();

        $nome = $row['Nome'];
        $telefone = $row['Telefone'];
        ?>
        <div class="new-experience">
            <div class="form-experience">
                <form action="<?php echo "../db/db_editUser.php?email=" . $email ?>" method="post">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="email">Email:</label>
                            <input type="text" id="email" name="email" style="width: 95%" required value="<?php echo "$email" ?>">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="nome">Nome:</label>
                            <input type="text" id="nome" name="nome" style="width: 95%" required value="<?php echo "$nome" ?>">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="telefone">Telefone:</label>
                            <input type="text" id="telefone" name="telefone" style="width: 95%" required value="<?php echo "$telefone" ?>">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="password">Password:</label>
                            <input type="text" id="password" name="password" style="width: 95%" required value="<?php echo "$password" ?>">
                        </div>
                    </div>
                    <button style="float:right;" type="submit">Guardar</button>
                </form>
            </div>
        </div>
    </div>
</body>

</html>