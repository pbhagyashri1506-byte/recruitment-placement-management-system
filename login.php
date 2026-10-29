<?php
include('db.php');
session_start();

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = mysqli_real_escape_string($conn, $_POST['email']);
    $password = $_POST['password'];
    $role = mysqli_real_escape_string($conn, $_POST['role']);

    $query = "SELECT * FROM users WHERE email='$email' AND role='$role'";
    $result = mysqli_query($conn, $query);

    if ($row = mysqli_fetch_assoc($result)) {
        if (password_verify($password, $row['password'])) {
            $_SESSION['user'] = $row['fullname'];
            $_SESSION['role'] = $row['role'];
            
            // Redirect based on role
            if ($role == 'student') {
                header("Location: dashboard_student.php");
            } elseif ($role == 'recruiter') {
                header("Location: dashboard_recruiter.php");
            } else {
                header("Location: dashboard_admin.php");
            }
            exit();
        } else {
            $error = "Invalid Password!";
        }
    } else {
        $error = "User not found or role mismatch!";
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Recruitment & Placement Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #1e3c72, #2a5298);
            color: white;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-card {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
        }
        .form-control, .form-select {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
        }
        .form-control::placeholder {
            color: #ddd;
        }
        .form-control:focus, .form-select:focus {
            background: rgba(255, 255, 255, 0.3);
            color: white;
        }
    </style>
</head>
<body>

    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-5 login-card">
                <h3 class="text-center mb-4 fw-bold">User Login</h3>
                
                <?php if(isset($error)) { echo "<div class='alert alert-danger'>$error</div>"; } ?>

                <form action="login.php" method="POST">
                    <div class="mb-3">
                        <label class="form-label">Email Address</label>
                        <input type="email" class="form-control" name="email" placeholder="Enter your email" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Password</label>
                        <input type="password" class="form-control" name="password" placeholder="Enter your password" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Login As</label>
                        <select class="form-select" name="role">
                            <option value="student" class="text-dark">Student</option>
                            <option value="recruiter" class="text-dark">Recruiter</option>
                            <option value="admin" class="text-dark">Admin</option>
                        </select>
                    </div>
                    <div class="d-grid gap-2 mb-3">
                        <button type="submit" class="btn btn-light text-primary fw-bold">Login</button>
                    </div>
                    <div class="text-center">
                        <p class="mb-0">Don't have an account? <a href="register.php" class="text-warning text-decoration-none">Register here</a></p>
                    </div>
                </form>
            </div>
        </div>
    </div>

</body>
</html>
