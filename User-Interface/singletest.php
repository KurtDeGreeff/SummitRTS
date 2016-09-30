<!DOCTYPE html>
<html lang="en">
<?php
	$ViewTestId=$_GET['test_id'];
?>
<?php
if (!empty($_GET['test_id'])) {
	//Grab the test name from the test id in the db for display.
	include 'components/database.php';
	$sql = "select Name as Test_name from TEST_SUITES where ID = $ViewTestId";
	$pdo = Database::connect();
	foreach ($pdo->query($sql) as $row) {
		''. $row['Test_name'] .'';
	}
} 
if (!empty($_GET['sut_id'])) {
	$SUT_id=$_GET['sut_id'];
	// Update the database to set the test to aborted
	$sql = "UPDATE SUTs SET Status_ID = 10 WHERE ID = $SUT_id";
	$pdo->query($sql);
	//Send the user back to the same page (without get)
	header("Refresh:0 url=Singletest.php?test_id=$ViewTestId");
} else {
	

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
				<h3>Summit RTS Test Results for test: <?php echo ''. $row['Test_name'] .'' ?></h3>
				<div class="row">
					<table id="example" class="table table-striped table-bordered">
						<thead>
							<tr>
							<th></th>
							<th>ID</th>
							<th>Name</th>
							<th>Status</th>
							<th>Template_Name</th>
							<th>HyperVisor Type</th>
							<th>Hypervisor IP</th>
							<th>Agent IP</th>
							<th>Workflow</th>
							<th>SUT Type</th>
							<th>Logfile</th>
							<th>IP Address</th>
							<th>date_modified</th>
							<th>Action</th>
							</tr>
						</thead>
						<tbody>
							<?php 
							//include 'components/database.php';
							$pdo = Database::connect();
							$sql = "select sut.ID, " 
										. "sut.Name, "
										. "sut.Status_ID, "
										. "sut.Test_Suite_ID, "
										. "sut.VM_Template_ID, "
										. "sut.Hypervisor_Type_ID, "
										. "sut.Hypervisor_ID, "
										. "sut.Agent_Manager_ID, "
										. "sut.Workflow_ID, "
										. "sut.SUT_Type_ID, "
										. "sut.IP_Address, "
										. "sut.Log_File, "
										. "sut.Remote_Console_URL, "
										. "sut.Console_Active, "
										. "s.HtmlColor, "
										. "s.Status, "
										. "s.ID as StatusID, "
										. "ts.Name as TestName, "
										. "vt.Ref_Name, "
										. "ht.Name as Hypervisor_Type, "
										. "h.IP_Address as Hyp_IP, "
										. "am.IP_Address as AGM_IP, "
										. "w.Name as Workflow_Name, "
										. "st.Name as SUT_Type, "
										. "sut.date_modified "
									. "from SUTs sut "
									. "join status s on sut.Status_ID=s.ID "
									. "join TEST_SUITES ts on sut.Test_Suite_ID=ts.ID "
									. "join VM_TEMPLATES vt on sut.VM_Template_ID=vt.ID "
									. "join HYPERVISOR_TYPES ht on sut.Hypervisor_Type_ID=ht.ID "
									. "join HYPERVISORS h on sut.Hypervisor_ID=h.ID "
									. "join AGENT_MANAGERS am on sut.Agent_Manager_ID=am.ID "
									. "join WORKFLOWS w on sut.Workflow_ID=w.ID "
									. "join SUT_TYPE st on sut.SUT_Type_ID=st.ID "
									. "where Test_Suite_ID = $ViewTestId";
	
							foreach ($pdo->query($sql) as $row) {
								echo '<tr>';
								if ($row['Console_Active'] == 1){
									echo '<td><a href="' . $row['Remote_Console_URL'] . '" target="_blank"><img src="img/console.png"></a></td>';
								} else {
									echo '<td><img src="img/noconsole.png"></td>';
								}
								echo '<td>'. $row['ID'] . '</td>';
								echo '<td>'. $row['Name'] . '</td>';
								echo '<td style=background-color:'. $row['HtmlColor'] . '>'. $row['Status'] . '</td>';
								echo '<td>'. $row['Ref_Name'] . '</td>';
								echo '<td>'. $row['Hypervisor_Type'] . '</td>';
								echo '<td>'. $row['Hyp_IP'] . '</td>';
								echo '<td>'. $row['AGM_IP'] . '</td>';
								echo '<td>'. $row['Workflow_Name'] . '</td>';
								echo '<td>'. $row['SUT_Type'] . '</td>';
								echo '<td><form action="singlelog.php" method="get"><input type="hidden" name="Log_File_Path" value='.$row['Log_File'].'><input type="submit" class="btn btn-info" value="View Log"></form></td>';
								echo '<td>'. $row['IP_Address'] . '</td>';
								echo '<td>'. $row['date_modified'] . '</td>';
								echo '<td width=250>';
								echo '<form action="singleSUT.php" method="get"><input type="hidden" name="sut_id" value='. $row['ID'] .'><input type="submit" class="btn btn-info" value="View SUT"></form>';
								echo '&nbsp';
								if ($row['StatusID'] == 9){
									echo '';
								} elseif ($row['StatusID'] == 10){
									echo '';
								} else {
									echo "<form action='singletest.php' method='get'><input type='hidden' name='test_id' value='$ViewTestId'><input type='hidden' name='sut_id' value=".$row['ID']."><input type='submit' class='btn btn-danger' value='Abort SUT'></form>";
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