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
				<h3>Summit RTS Sut's</h3>
				<div class="row">
					<table id="example" class="table table-striped table-bordered">
						<thead>
							<tr>
							<th>ID</th>
							<th>Name</th>
							<th>Status</th>
							<th>Test_Suite</th>
							<th>VM_Template</th>
							<th>Hypervisor_Type</th>
							<th>Hypervisor_MGR</th>
							<th>Agent_Manager</th>
							<th>Workflow</th>
							<th>SUT_Type</th>
							<th>Log_File</th>
							<th>IP_Address</th>
							<th>Remote_Console_URL</th>
							<th>Console_Active</th>
							<th>date_modified</th>
							<th>Action</th>
							</tr>
						</thead>
						<tbody>
							<?php 
							include 'components/database.php';
							$pdo = Database::connect();
							$sql = 'select sut.ID, '
										. 'sut.Name, '
										. 'sut.Status_ID, '
										. 'sut.Test_Suite_ID, '
										. 'sut.VM_Template_ID, '
										. 'sut.Hypervisor_Type_ID, '
										. 'sut.Hypervisor_ID, '
										. 'sut.Agent_Manager_ID, '
										. 'sut.Workflow_ID, '
										. 'sut.SUT_Type_ID, '
										. 'sut.Log_File, '
										. 'sut.IP_Address, '
										. 'sut.Remote_Console_URL, '
										. 'sut.Console_Active, '
										. 'sut.date_modified, '
										. 's.Status, '
										. 's.HtmlColor, '
										. 'ts.Name as TestSuite_Name, '
										. 'vt.Ref_Name, '
										. 'ht.Name as Hypervisor_Type, '
										. 'h.IP_Address as Hypervisor_IP, '
										. 'am.IP_Address as Agent_MGR_IP, '
										. 'w.Name as Workflow_Name, '
										. 'st.Name as SUT_Type '
									. 'from SUTs sut '
									. 'join status s on sut.Status_ID=s.ID '
									. 'join TEST_SUITES ts on sut.Test_Suite_ID=ts.ID '
									. 'join VM_TEMPLATES vt on sut.VM_Template_ID=vt.ID '
									. 'join HYPERVISOR_TYPES ht on sut.Hypervisor_Type_ID=ht.ID '
									. 'join HYPERVISORS h on sut.Hypervisor_ID=h.ID '
									. 'join AGENT_MANAGERS am on sut.Agent_Manager_ID=am.ID '
									. 'join WORKFLOWS w on sut.Workflow_ID=w.ID '
									. 'join SUT_TYPE st on sut.SUT_Type_ID=st.ID ';

							foreach ($pdo->query($sql) as $row) {
								echo '<tr>';
								echo '<td>'. $row['ID'] . '</td>';
								echo '<td>'. $row['Name'] . '</td>';
								echo '<td bgcolor='. $row['HtmlColor'] .'>'. $row['Status'] . '</td>';
								echo '<td>'. $row['TestSuite_Name'] . '</td>';
								echo '<td>'. $row['Ref_Name'] . '</td>';
								echo '<td>'. $row['Hypervisor_Type'] . '</td>';
								echo '<td>'. $row['Hypervisor_IP'] . '</td>';
								echo '<td>'. $row['Agent_MGR_IP'] . '</td>';
								echo '<td>'. $row['Workflow_Name'] . '</td>';
								echo '<td>'. $row['SUT_Type'] . '</td>';
								echo '<td>'. $row['Log_File'] . '</td>';
								echo '<td>'. $row['IP_Address'] . '</td>';
								echo '<td>'. $row['Remote_Console_URL'] . '</td>';
								echo '<td>'. $row['Console_Active'] . '</td>';
								echo '<td>'. $row['date_modified'] . '</td>';
								echo '<td width=250><a class="btn" href="viewTestSuite.php?id='.$row['ID'].'">ViewTest</a></td>';
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