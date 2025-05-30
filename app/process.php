<?php
require 'vendor/autoload.php';

use Aws\S3\S3Client;
use Dotenv\Dotenv;

// Load environment variables from .env file
$dotenv = Dotenv::createImmutable(__DIR__);
$dotenv->load();

// Fetch database credentials from environment variables
$db_host = $_ENV['DB_HOST'];
$db_user = $_ENV['DB_USER'];
$db_pass = $_ENV['DB_PASSWORD'];
$db_name = $_ENV['DB_NAME'];

// Create database connection
$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Create table if it doesn't exist
$table_query = "
CREATE TABLE IF NOT EXISTS contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    attachment VARCHAR(255) DEFAULT NULL
)";
$conn->query($table_query);

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $name = $_POST['name'];
    $email = $_POST['email'];
    $message = $_POST['message'];
    $attachment = '';

    // Upload to S3 if file is uploaded
    if (isset($_FILES['attachment']) && $_FILES['attachment']['error'] == 0) {
        $s3 = new S3Client([
            'version' => 'latest',
            'region'  => $_ENV['AWS_DEFAULT_REGION']
        ]);

        $bucket = $_ENV['S3_BUCKET_NAME'];
        $key = 'uploads/' . basename($_FILES['attachment']['name']);
        $file_path = $_FILES['attachment']['tmp_name'];

        try {
            $result = $s3->putObject([
                'Bucket' => $bucket,
                'Key'    => $key,
                'SourceFile' => $file_path,
                //'ACL'    => 'public-read' // Optional: adjust permissions as needed
            ]);
            $attachment = $result['ObjectURL'];
        } catch (Exception $e) {
            echo "There was an error uploading the file.\n";
            echo $e->getMessage();
        }
    }

    $stmt = $conn->prepare("INSERT INTO contacts (name, email, message, attachment) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $name, $email, $message, $attachment);

    if ($stmt->execute()) {
        echo "Message sent successfully!";
    } else {
        echo "Error: " . $stmt->error;
    }

    $stmt->close();
}

$conn->close();