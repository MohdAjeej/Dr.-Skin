# Dr.Skin App Environment Setup Script
# This script sets up all required environment variables for the project

# Set Java Home to Java 17
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-17", "User")

# Add Java to PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$javaPath = "C:\Program Files\Java\jdk-17\bin"
if ($currentPath -notlike "*$javaPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$javaPath", "User")
}

# Add FVM/Dart to PATH
$fvmPath = "$env:USERPROFILE\AppData\Local\Pub\Cache\bin"
if ($currentPath -notlike "*$fvmPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$fvmPath", "User")
}

# Temporary session variables
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

Write-Host "Environment variables configured successfully!"
Write-Host "JAVA_HOME: $env:JAVA_HOME"
Write-Host "Java version:"
java -version
Write-Host "`nFVM version:"
fvm --version
Write-Host "`nFlutter doctor:"
fvm flutter doctor