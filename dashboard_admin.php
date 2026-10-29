<?php
session_start();
if (!isset($_SESSION['user']) || $_SESSION['role'] != 'admin') {
    header("Location: login.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - RPMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">Admin Dashboard</a>
            <div class="d-flex">
                <span class="text-white me-3 align-self-center">Welcome, <?php echo htmlspecialchars($_SESSION['user']); ?></span>
                <a href="login.php" class="btn btn-danger btn-sm">Logout</a>
            </div>
        </div>
    </nav>

    <div class="container mt-5">
        <div class="row">
            <div class="col-md-12">
                <div class="card shadow-sm p-4">
                    <h2>System Administration</h2>
                    <p class="text-muted">Manage users, view system reports, and oversee placements.</p>
                    <hr>
                    <div class="alert alert-warning">Admin controls and user management panel coming up here!</div>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
