<?php
session_start();
if (!isset($_SESSION['user']) || $_SESSION['role'] != 'recruiter') {
    header("Location: login.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recruiter Dashboard - RPMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <nav class="navbar navbar-expand-lg navbar-dark bg-success">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">Recruiter Dashboard</a>
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
                    <h2>Manage Job Postings</h2>
                    <p class="text-muted">Post new job openings and review candidate applications.</p>
                    <hr>
                    <div class="alert alert-success">You can post new jobs from here soon!</div>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
