<!DOCTYPE html>
<html lang="en">
<?php
	$Log_Path=$_GET['Log_File'];  //value will be LogFile_Path
?>
<?php
	require_once 'components/header.php';
?>
<head>
    <meta charset="utf-8">
	<link href="css/styles.css" rel="stylesheet" />
	<link href="https://netdna.bootstrapcdn.com/bootstrap/3.0.3/css/bootstrap.min.css" rel="stylesheet" />
	<link href="https://cdn.datatables.net/plug-ins/1.10.7/integration/bootstrap/3/dataTables.bootstrap.css" rel="stylesheet" />
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
	<script src="https://cdn.datatables.net/1.10.7/js/jquery.dataTables.min.js"></script>
	<script src="https://cdn.datatables.net/plug-ins/1.10.7/integration/bootstrap/3/dataTables.bootstrap.js"></script>

</head>
<script> 
	$(document).ready(function() {
		$('#example').dataTable();
	});
</script>
<body>
    <div class="container-fluid">
    	<div class="row">
			<?php
				require_once 'components/Side_Bar.html';
			?>
			<div class="col-sm-9 col-md-10 col-lg-10 main">
				<h3>Summit RTS Logfile:</h3>
				<div class="row">
		<?php
		$findstr = 'png';
		$pos = strpos($Log_Path, $findstr);
		if ($pos === false) {
			$myfile = fopen("$Log_Path", "r") or die("Unable to open //file!");
			$pageText = fread($myfile,filesize("$Log_Path"));
			echo '<table class="table-striped table-bordered"><tr><td>'. nl2br($pageText) .'</td></tr></table>';
			fclose($myfile);
		}
		else {
			echo "<a href='singleImage.php?Log_Path=$Log_Path' target='_blank'>View Image</a>";
		}
		?>
			</div>
		</div>
	</div> <!-- /container -->
</body>
<?php
	require_once 'components/footer.php';
?>
</html>