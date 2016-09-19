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
				<h3>Summit RTS Available Software Information</h3>
				<div class="row">
					<p>
						<a href="createVMTemplate.php" class="btn btn-success">Create</a>
					</p>
					<table id="example" class="table table-striped table-bordered">
						<thead>
							<tr>
							<th>ID</th>
							<th>Ref_Name</th>
							<th>Manufacturer</th>
							<th>Name</th>
							<th>Version</th>
							<th>date_modified</th>
							<th>Action</th>
							</tr>
						</thead>
						<tbody>
							<?php 
							include 'components/database.php';
							$pdo = Database::connect();
							$sql = 'select a.ID,' 
										. 'a.Software_ID,'
										. 'a.VM_Template_ID,'
										. 'vt.Ref_Name,'
										. 's.Manufacturer,'
										. 's.Name, '
										. 's.Version, '
										. 's.date_modified '
									. 'from AVAILABLE_SOFTWARE a '
									. 'join software s on a.Software_ID=s.ID '
									. 'join VM_TEMPLATES vt on a.VM_Template_ID=vt.ID ';
							
							foreach ($pdo->query($sql) as $row) {
								echo '<tr>';
								echo '<td>'. $row['ID'] . '</td>';
								echo '<td>'. $row['Ref_Name'] . '</td>';
								echo '<td>'. $row['Manufacturer'] . '</td>';
								echo '<td>'. $row['Name'] . '</td>';
								echo '<td>'. $row['Version'] . '</td>';
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