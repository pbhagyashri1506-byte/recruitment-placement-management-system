<?php
session_start();
if (!isset($_SESSION['user']) || $_SESSION['role'] != 'student') {
    header("Location: login.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - RPMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">Student Dashboard</a>
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
                    <h2>Available Job Listings</h2>
                    <p class="text-muted">Browse and apply for placement drives here.</p>
                    <hr>
                    <div class="alert alert-info">No job listings available right now. Check back later!</div>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
