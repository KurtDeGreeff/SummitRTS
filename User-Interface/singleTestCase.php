<!DOCTYPE html>
<html lang="en">
<?php
	$testcase_id=$_GET['testcase_id'];
?>
<?php
if (!empty($_GET['testcase_id'])) {
	//Grab the test name from the test id in the db for display.
	include 'components/database.php';
	$sql = "select tc.ID, "
			. "tc.Name, "
			. "tc.SUT_ID, "
			. "tc.Status_ID, "
			. "tc.Result_ID, "
			. "sut.Name as SUT_Name, "
			. "sut.Log_File as Agent_Log, "
			. "tcs.Test_Case_ID, "
			. "tcs.Script_Path, "
			. "s.Status, "
			. "s.HtmlColor as Status_Color, "
			. "tr.Name as Result_Name, "
			. "tr.HtmlColor as Result_Color "
			. "from TEST_CASES tc "
			. "join SUTs sut on tc.SUT_ID=sut.ID "
			. "join Status s on tc.Status_ID=s.ID "
			. "join TEST_CASE_SCRIPTS tcs on tc.ID=tcs.Test_Case_ID "
			. "join TEST_RESULT tr on tc.Result_ID=tr.ID "
			. "where tc.ID = $testcase_id";
	$pdo = Database::connect();
	foreach ($pdo->query($sql) as $row) {
		''. $row['Name'] .'';
		''. $row['SUT_Name'] .'';
		''. $row['Status'] .'';
		''. $row['Status_Color'] .'';
		''. $row['Result_Name'] .'';
		''. $row['Result_Color'] .'';
		''. $row['Agent_Log'] .'';
		''. $row['Script_Path'] .'';
	}
} 

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
				<h3>Summit RTS Test Results for TestCase:</h3>
				<div class="row">
		<table class="table table-striped table-bordered">
			<tr>
			<th>SUT Name</th>
			<th>TestCase Name</th>
			<th>Script_Path</th>
			<th>Status</th>
			<th>Result</th>
			<th>Logfile</th>
			</tr>
			<tr>
			<?php
			echo '<td>'. $row['SUT_Name'] .'</td>';
			echo '<td>'. $row['Name'] .'</td>';
			echo '<td>'. $row['Script_Path'] .'</td>';
			echo '<td style=background-color:'. $row['Status_Color'] . '>'. $row['Status'] . '</td>';
			echo '<td style=background-color:'. $row['Result_Color'] . '>'. $row['Result_Name'] . '</td>';
			echo '<td><form action="singleLogByName.php" method="get"><input type="hidden" name="Log_File" value='.$row['Agent_Log'].'><input type="submit" class="btn btn-info" value="View Log"></form></td>';
			echo '</tr>';
			?>
		</table>
					<table id="example" class="table table-striped table-bordered">
						<thead>
							<tr>
							<th>ID</th>
							<th>Log Name</th>
							<th>Log_Path</th>
							<th>date_modified</th>
							<th>Action</th>
							</tr>
						</thead>
						<tbody>
							<?php 
							//include 'components/database.php';
							$pdo = Database::connect();
							$sql = "select tcl.ID, "
										. "tcl.Test_Case_ID, "
										. "tcl.Log_Path, "
										. "tcl.Log_File_Name, "
										. "tcl.date_modified "
									. "from TEST_CASE_LOG_FILES tcl "
									. "where tcl.Test_Case_ID = $testcase_id ";
	
							foreach ($pdo->query($sql) as $row) {
								echo '<tr>';
								echo '<td>'. $row['ID'] . '</td>';
								echo '<td>'. $row['Log_File_Name'] . '</td>';		
								echo '<td>'. $row['Log_Path'] . '</td>';
								echo '<td>'. $row['date_modified'] . '</td>';
							   	echo '<td>';							   	
							   	echo '<form action="singlelog.php" method="get"><input type="hidden" name="Log_File_ID" value='.$row['ID'].'><input type="submit" class="btn btn-info" value="View Log"></form>';
							   	echo '</td>';
								echo '</tr>';
							}
							Database::disconnect();
							?>
						</tbody>
					</table>
		   		</div>
			</div>
		</div>
	</div> <!-- /container -->
</body>
<?php
	require_once 'components/footer.php';
?>
</html>