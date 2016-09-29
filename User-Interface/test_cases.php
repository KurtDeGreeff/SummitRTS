<!DOCTYPE html>
<html lang="en">
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
				<h3>Summit RTS Test Cases</h3>
				<div class="row">
					<table id="example" class="table table-striped table-bordered">
						<thead>
							<tr>
							<th>ID</th>
							<th>Name</th>
							<th>SUT_Name</th>
							<th>Status</th>
							<th>Result</th>
							<th>Order_Index</th>
							<th>date_modified</th>
							<th>Action</th>
							</tr>
						</thead>
						<tbody>
							<?php 
							include 'components/database.php';
							$pdo = Database::connect();
							$sql = 'select tc.ID, '
										. 'tc.Name, '
										. 'tc.SUT_ID, '
										. 'tc.Status_ID, '
										. 'tc.Result_ID, '
										. 'tc.Order_Index, '
										. 'tc.date_modified, '
										. 'sut.Name as SUT_NAME, '
										. 's.Status, '
										. 's.HtmlColor as Status_Color, '
										. 'tr.Name as Result_Name, '
										. 'tr.HtmlColor as Result_Color '
									. 'from TEST_CASES tc '
									. 'join SUTS sut on tc.SUT_ID=sut.ID '
									. 'join Status s on tc.Status_ID=s.ID '
									. 'join TEST_RESULT tr on tc.Result_ID=tr.ID ';
						
							foreach ($pdo->query($sql) as $row) {
								echo '<tr>';
								echo '<td>'. $row['ID'] . '</td>';
								echo '<td>'. $row['Name'] . '</td>';		
								echo '<td>'. $row['SUT_NAME'] . '</td>';
								echo '<td style=background-color:'. $row['Status_Color'] . '>'. $row['Status'] . '</td>';
								echo '<td style=background-color:'. $row['Result_Color'] . '>'. $row['Result_Name'] . '</td>';
								echo '<td>'. $row['Order_Index'] . '</td>';
								echo '<td>'. $row['date_modified'] . '</td>';
							   	echo '<td>';							   	
								echo '&nbsp;';
							   	echo '<a class="btn btn-info" href="update.php?id='.$row['ID'].'">View Logs</a>';
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