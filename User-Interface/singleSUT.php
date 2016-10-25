<!DOCTYPE html>
<html lang="en">
<?php
	$SUT_id=$_GET['sut_id'];
?>
<?php
if (!empty($_GET['sut_id'])) {
	//Grab the test name from the test id in the db for display.
	include 'components/database.php';
	$sql = "select Remote_Console_URL, Console_Active, Log_File as Agent_Log, Name as SUT_name from SUTs where ID = $SUT_id";
	$pdo = Database::connect();
	foreach ($pdo->query($sql) as $row) {
		''. $row['SUT_name'] .'';
		''. $row['Remote_Console_URL'] .'';
		''. $row['Console_Active'] .'';
		''. $row['Agent_Log'] .'';
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
				<h3>Summit RTS Test Results for SUT:</h3>
				<div class="row">
		<table class="table table-striped table-bordered">
			<tr>
			<th>Console</th>
			<th>SUT Name</th>
			<th>Logfile</th>
			</tr>
			<tr>
			<?php
			if ($row['Console_Active'] == 1){
				echo '<td><a href="' . $row['Remote_Console_URL'] . '" target="_blank"><img src="img/console.png"> Watch Test Live</a></td>';
			} else {
				echo '<td><img src="img/noconsole.png"></td>';
			}
			echo '<td>'. $row['SUT_name'] .'</td>';
			echo '<td><form action="singlelog.php" method="get"><input type="hidden" name="Log_File_Path" value='.$row['Agent_Log'].'><input type="submit" class="btn btn-info" value="View Log"></form></td>';
			echo '</tr>';
			?>
		</table>
					<table id="example" class="table table-striped table-bordered">
						<thead>
							<tr>
							<th>ID</th>
							<th>Name</th>
							<th>Order_Index</th>
							<th>Status</th>
							<th>Result</th>
							<th>date_modified</th>
							<th>Action</th>
							</tr>
						</thead>
						<tbody>
							<?php 
							//include 'components/database.php';
							$pdo = Database::connect();
							$sql = "select DISTINCT tc.ID, "
										. "tc.Name, "
										. "tc.Order_Index, "
										. "tc.SUT_ID, "
										. "tc.Status_ID, "
										. "tc.Result_ID, "
										. "tc.date_modified, "
										. "tcs.Test_Case_ID, "
										. "s.Status, "
										. "s.HtmlColor as Status_Color, "
										. "tr.Name as Result_Name, "
										. "tr.HtmlColor as Result_Color "
									. "from TEST_CASES tc "
									. "join Status s on tc.Status_ID=s.ID "
									. "join TEST_RESULT tr on tc.Result_ID=tr.ID "
									. "join TEST_CASE_SCRIPTS tcs on tc.ID=tcs.Test_Case_ID "
									. "where tc.SUT_ID = $SUT_id "
									. "Order by tc.Order_Index ASC ";
	
							foreach ($pdo->query($sql) as $row) {
								echo '<tr>';
								echo '<td>'. $row['ID'] . '</td>';
								echo '<td>'. $row['Name'] . '</td>';		
								echo '<td>'. $row['Order_Index'] . '</td>';
								echo '<td style=background-color:'. $row['Status_Color'] . '>'. $row['Status'] . '</td>';
								echo '<td style=background-color:'. $row['Result_Color'] . '>'. $row['Result_Name'] . '</td>';
								echo '<td>'. $row['date_modified'] . '</td>';
							   	echo '<td>';							   	
							   	echo '<form action="singleTestCase.php" method="get"><input type="hidden" name="testcase_id" value='.$row['ID'].'><input type="submit" class="btn btn-info" value="View TestCase"></form>';
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