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
				<h3>Summit RTS Available Workflows</h3>
				<div class="row">
					<p>
						<a href="createAvailWorkflow.php" class="btn btn-success">Create</a>
					</p>
					<table id="example" class="table table-striped table-bordered">
						<thead>
							<tr>
							<th>ID</th>
							<th>Agent_MGR_IP</th>
							<th>Hypervisor Type</th>
							<th>Workflow_Name</th>
							<th>Status</th>
							<th>date_modified</th>
							<th>Action</th>
							</tr>
						</thead>
						<tbody>
							<?php 
							include 'components/database.php';
							$pdo = Database::connect();
							$sql = 'select aw.ID, ' 
										. 'aw.Agent_Mgr_ID, '
										. 'aw.Hypervisor_Type_ID, '
										. 'aw.Workflow_ID, '
										. 'aw.Status_ID, '
										. 'am.IP_Address, '
										. 'ht.Name as Hypervisor_Type, '
										. 'w.Name, '
										. 'am.date_modified, '
										. 's.Status, '
										. 's.HtmlColor '
									. 'from AVAILABLE_WORKFLOWS aw '
									. 'join AGENT_MANAGERS am on aw.Agent_Mgr_ID=am.ID '
									. 'join HYPERVISOR_TYPES ht on aw.Hypervisor_Type_ID=ht.ID '
									. 'join WORKFLOWS w on aw.Workflow_ID=w.ID '
									. 'join STATUS s on aw.Status_ID=s.ID ';
						
							foreach ($pdo->query($sql) as $row) {
								echo '<tr>';
								echo '<td>'. $row['ID'] . '</td>';
								echo '<td>'. $row['IP_Address'] . '</td>';		
								echo '<td>'. $row['Hypervisor_Type'] . '</td>';		
								echo '<td>'. $row['Name'] . '</td>';
								echo '<td style=background-color:'. $row['HtmlColor'] . '>' . $row['Status'] . '</td>';
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