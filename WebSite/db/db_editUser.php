<?php
session_start();
function validate($data)
{
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data);
    return $data;
}

$url = "127.0.0.1";
$database = "grupo12_bd";
$username = $_SESSION['email'];
$password = $_SESSION['password'];
$conn = mysqli_connect($url, $username, $password, $database);

$email = $_GET['email'];

$newEmail = validate($_POST['email']);
$newNome = validate($_POST['nome']);
$newTelefone = validate($_POST['telefone']);
$newPassword = validate($_POST['password']);
$tipoUtilizador = NULL;

$stmt = $conn->prepare("CALL EditarUtilizador(?, ?, ?, ?, ?, ?)");

// Bind the parameters to the SQL statement
$stmt->bind_param("ssssss", $email, $newEmail, $newNome, $tipoUtilizador, $newTelefone, $newPassword);

// Execute the SQL statement
$stmt->execute();

// Close the statement
$stmt->close();

//redirects to experiences.php
header("Location: ../home/experiences.php");
$conn->close();
exit();
