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
				<h3>Summit RTS Agent Managers</h3>
				<div class="row">
					<p>
						<a href="createAgentMgr.php" class="btn btn-success">Create</a>
					</p>
					<table id="example" class="table table-striped table-bordered">
						<thead>
							<tr>
							<th>ID</th>
							<th>IP_Address</th>
							<th>Status</th>
							<th>Wait</th>
							<th>LogFile</th>
							<th>date_modified</th>
							<th>Action</th>
							</tr>
						</thead>
						<tbody>
							<?php 
							include 'components/database.php';
							$pdo = Database::connect();
							$sql = 'select am.ID, ' 
										. 'am.IP_Address, '
										. 'am.Status_ID, '
										. 's.Status, '
										. 's.HtmlColor, '
										. 'am.Wait, '
										. 'am.LogFile, '
										. 'am.date_modified '
									. 'from AGENT_MANAGERS am '
									. 'join status s on am.Status_ID=s.ID ';
						
							foreach ($pdo->query($sql) as $row) {
								echo '<tr>';
								echo '<td>'. $row['ID'] . '</td>';
								echo '<td>'. $row['IP_Address'] . '</td>';
								echo '<td bgcolor='. $row['HtmlColor'] . '>' . $row['Status'] . '</td>';								
								echo '<td>'. $row['Wait'] . '</td>';
								echo '<td>'. $row['LogFile'] . '</td>';
								echo '<td>'. $row['date_modified'] . '</td>';
							   	echo '<td>';							   	
								echo '&nbsp;';
							   	echo '<a class="btn btn-success" href="update.php?id='.$row['ID'].'">Update</a>';
							   	echo '&nbsp;';
							   	echo '<a class="btn btn-danger" href="delete.php?id='.$row['ID'].'">Delete</a>';
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