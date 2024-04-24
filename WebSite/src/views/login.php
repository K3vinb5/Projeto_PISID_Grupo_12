<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Archivo%20Black&amp;display=swap">
    <script src="https://unpkg.com/htmx.org@1.9.11"
        integrity="sha384-0gxUXCCR8yv9FM2b+U3FDbsKthCI66oH5IA9fHppQq9DDMHuMauqq1ZHBpJxQ0J0"
        crossorigin="anonymous"></script>
    <script src="https://unpkg.com/hyperscript.org@0.9.12"></script>
    <link rel="stylesheet" href="../css/login.css">
    <title>Ratos e Ratinhos</title>
</head>

<body class="container">
    <?php
        session_start();
        if(isset($_SESSION["wrong_user_pass"])) {
            echo '<div hx-get="./modal.html"
                hx-trigger="load delay:0.5s"
                hx-swap="beforeend">
             </div>';
            unset($_SESSION["wrong_user_pass"]);
        }

    ?>
    <aside class="aside-project-name">
        <article class="project-name shadow-box">
            <p class="local-name">LABORATÓRIO</p>
            <p class="company-name">RATOS&CO</p>
            <p class="sponsors">FINANCIADO POR ISCTE-IUL</p>
        </article>
    </aside>
    <form class="form" action="../php/login.php" method="post">
        <div class="form-elements extra-padding">
            <fieldset class="group-input">
                <legend class="input-legend">Username</legend>
                <input class="input" type="text" id="username" name="username" required="">
            </fieldset>

            <fieldset class="group-input extra-margin">
                <legend class="input-legend">Password</legend>
                <input class="input" type="password" id="password" name="password" required="">
            </fieldset>
            <button class="btn-login extra-margin" type="submit">LOGIN</button>
        </div>
    </form>
</body>

</html>