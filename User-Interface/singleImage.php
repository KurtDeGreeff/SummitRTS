<?php
header("Content-Type: image/png"); // or image/gif, depending on what $LogFilePath is.
$LogFilePath=$_GET['Log_Path'];  //value will be LogFile_Path
$handle = fopen($LogFilePath, "rb");
$contents = fread($handle, filesize($LogFilePath));
echo $contents;