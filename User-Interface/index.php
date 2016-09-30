<!DOCTYPE html>
<html lang="en">
<?php
if (!empty($_GET['test_id'])) {
	$TestId=$_GET['test_id'];
	include 'components/database.php';
	// Update the database to set the test to aborted
	$sql = "UPDATE TEST_SUITES SET Status_ID = 10 WHERE ID = $TestId";
	$pdo = Database::connect();
	$pdo->query($sql);
	Database::disconnect();
	// Send the user back to the same page
	header("Refresh:0 url=index.php");
} else {
	//It'd be nice to grab the test name from the test id in the db for display.
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
				<h3>Summit RTS Test Results</h3>
				<div class="row">
					<table id="example" class="table table-striped table-bordered">
						<thead>
							<tr>
							<th>ID</th>
							<th>Name</th>
							<th>Status</th>
							<th>Total_SUT</th>
							<th>date_modified</th>
							<th>Action</th>
							</tr>
						</thead>
						<tbody>
							<?php 
							include 'components/database.php';
							$pdo = Database::connect();
							$sql = 'select ts.ID, ' 
										. 'ts.Name, '
										. 's.Status, '
										. 's.HtmlColor, '
										. 's.ID as statusID, '
										. 'ts.Total_SUT, '
										. 'ts.Status_ID, '
										. 'ts.date_modified '
									. 'from test_suites ts '
									. 'join status s on ts.Status_ID=s.ID ';
	
							foreach ($pdo->query($sql) as $row) {
								echo '<tr>';
								echo '<td>'. $row['ID'] . '</td>';
								echo '<td>'. $row['Name'] . '</td>';
								echo '<td style=background-color:'. $row['HtmlColor'] . '>'. $row['Status'] . '</td>';
								echo '<td>'. $row['Total_SUT'] . '</td>';
								echo '<td>'. $row['date_modified'] . '</td>';
								echo '<td width=250>';
								echo '<form action="singletest.php" method="get"><input type="hidden" name="test_id" value='.$row['ID'].'><input type="submit" class="btn btn-info" value="View Test"></form>';
								if ($row['statusID'] == 9){
									echo '';
								} elseif ($row['statusID'] == 10){
									echo '';
								} else {
									echo '<form action="index.php" method="get"><input type="hidden" name="test_id" value='.$row['ID'].'><input type="submit" class="btn btn-danger" value="Abort Test"></form>';
								}
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
<?php
  }
?>
</html>