use SummitRTS;

INSERT INTO STATUS (ID, Status, HtmlColor, HTML_Description)
VALUES (1,'Down','#CC0000','Red'),
(2,'Up','#006633','Green'),
(3,'Starting Up','#FFFF00','Yellow'),
(4,'Shutting Down','#FF6600','Orange'),
(5,'Submitted','#666666','Grey'),
(6,'Queued','#FFFFFF','White'),
(7,'Assigned','#6699FF','SkyBlue'),
(8,'Running','#0066FF','Blue'),
(9,'Complete','#00CC66','LightGreen'),
(10,'Cancelled','#333333','Charcoal');

INSERT INTO TEST_RESULT (ID, Name, HtmlColor, HTML_Description)
VALUES (1,'PASS','#006633','Green'),
(2,'FAIL','#CC0000','Red'),
(3,'CRITICAL','#FFFF00','Yellow'),
(4,'AGENT_ERROR','#9933FF','Purple'),
(5,'ABORTED','#FF6600','Orange'),
(6,'UNKNOWN','#666666','Grey');

INSERT INTO QUEUE_MANAGER (Status_ID, Wait, Log_File)
VALUES (1,60,'c"\\SummitRTS\\Queue_Manager\\Queue_Manager.log');

INSERT INTO RTS_PROPERTIES (Name, Val)
VALUES ('WIN_SHARE','\\\\192.168.2.68\\dropbox'),('WIN_SHARE_USER','DeviceUser'),('WIN_SHARE_PASS','BelayTech2015'),('WIN_SHARE_SCRIPTS_DIR','\\sut-scripts\\WINDOWS'),('WIN_LOCAL_SCRIPTS_DIR','dropbox'),('WIN_LOGFILE_NAME','rts.log'),('WIN_RESULTS_SHARE','\\\\192.168.2.68\\share'),('LINUX_SHARED_DRIVE','/192.168.2.68/dropbox'),('LINUX_SHARE_USER','DeviceUser'),('LINUX_SHARE_PASS','BelayTech2015'),('LINUX_SHARE_SCRIPTS_DIR','/sut-scripts/LINUX'),('LINUX_LOCAL_SCRIPTS_DIR','/dropbox'),('LINUX_LOGFILE_NAME','rts.log'),('LINUX_RESULTS_SHARE','/192.168.2.68/share');

INSERT INTO Software (Manufacturer, Name, Version)
VALUES ('Google','Chrome','27.0.1'),('Apache','httpd','latest'),('Mozilla','Firefox','27.0.1');

INSERT INTO VM_TEMPLATES (ID, OS, OS_Version, OS_Service_Pack, OS_Arch, OS_User_Name, OS_User_PWD, OS_Type, Ref_Name)
VALUES (1,'Windows','7','SP1','32','administrator','BelayTech2015','Windows','Win_7_test_vm'),
(2,'Windows','10','Base','32','administrator','BelayTech2015','Windows','Win_10_test_vm'),
(3,'CentOS','6','Base','32','root','BelayTech2015','Linux','CentOS_6_test_vm'),
(4,'Android','4','Base','32','root','BelayTech2015','Android','Android_4_test_vm');

INSERT INTO AVAILABLE_SOFTWARE (ID, Software_ID, VM_Template_ID)
VALUES ('1','1','1'),('2','1','2'),('3','2','3'),('4','2','4');

INSERT INTO HYPERVISOR_TYPES(ID,Name)
VALUES (1,'vSphere'),(2,'vmwks'),(3,'vBox');

INSERT INTO HYPERVISORS (ID, Hypervisor_Type_ID, IP_Address, Username, Password, Version, Mgmt_IP, Datacenter, Datastore, Max_Concurrent_SUTS, Active)
VALUES (1,1,'192.168.10.55','administrator@vcenter6u1.local','BelayTech2016!','6','192.168.10.105','Device','datastore11',1,0),
(2,1, '192.168.10.54','root','BelayTech2016','5','192.168.10.86','Device','datastore-1',1,1),
(3,2,'127.0.0.1','administrator','BelayTech2016','12.0','127.0.0.1','Device','C:\\temp\\WKS',1,1),
(4,3,'127.0.0.2','administrator','BelayTech2016','5.0.14','127.0.0.2','Device','C:\\temp\\vbox',1,1);

INSERT INTO HYPERVISOR_VMS(ID, Hypervisor_ID, VM_Template_ID, Active, Tools_Available)
VALUES (1,1,1,1,1),(2,2,1,1,1),(3,3,1,1,1),(4,4,1,1,1),(5,1,2,0,1),(6,2,2,1,1),(7,3,2,1,1),(8,4,2,1,1),(9,1,3,0,1),(10,2,3,1,1),(11,3,3,0,1),(12,4,3,0,1),(13,1,4,0,0),(14,2,4,1,0),(15,3,4,0,0),(16,4,4,0,0);

INSERT INTO WORKFLOWS (ID, Name, Script_Path)
VALUES (1,'TestCase_Default','c:\\SummitRTS\\TestCase_Default'),
(2,'MultiMachine_Default','c:\\SummitRTS\\MultiMachine_Default');

INSERT INTO AGENT_MANAGERS (ID, IP_Address, STATUS_ID, Wait, Logfile)
VALUES (1, '127.0.0.1',1,60,'c:\\SummitRTS\\Agent_Manager\\Agent_Manager.log');

INSERT INTO AVAILABLE_WORKFLOWS (ID, Agent_Mgr_ID, Hypervisor_ID, Workflow_ID, Active)
VALUES (1,1,1,1,1),(2,1,1,2,1),(3,1,2,1,1),(4,1,2,2,1),(5,1,3,1,1),(6,1,3,2,1),(7,1,4,1,1),(8,1,4,2,1);

INSERT INTO TEST_SUITES (ID, Name, Status_ID, Total_SUT)
VALUES (1,'Sampletest1',5,2),(2,'Sampletest2',9,2);

INSERT INTO SUT_TYPE (ID, Name)
VALUES (1,'Transient'),(2,'Persistent');

-- Test 1 SUT's

INSERT INTO SUTs (ID, Name, Status_ID, Test_Suite_ID, VM_Template_ID, Hypervisor_Type_ID, Hypervisor_ID, Agent_Manager_ID, Workflow_ID, SUT_Type_ID, Log_File, IP_Address, Remote_Console_URL, Console_Active)
VALUES (1,'Sampletest1_001_Win_7_testvm',5,1,1,1,1,1,1,1,'c:\\share\\sutresults\\sampletest1\\Sampletest1_001_Win_7_testvm\\agent.log','192.168.10.198','https://192.168.2.60:9443/vsphere-client',1);

INSERT INTO SUTs (ID, Name, Status_ID, Test_Suite_ID, VM_Template_ID, Hypervisor_Type_ID, Hypervisor_ID, Agent_Manager_ID, Workflow_ID, SUT_Type_ID, Log_File, IP_Address, Remote_Console_URL, Console_Active)
VALUES (2,'Sampletest1_002_Win_10_testvm',5,1,2,1,2,1,1,1,'c:\\share\\sutresults\\sampletest1\\Sampletest1_001_Win_10_testvm\\agent.log','192.168.10.199','https://192.168.2.60:9443/vsphere-client',1);

-- Test 1 SUT 1 Test Cases and scripts

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (1,'provisioning',1,9,1,1);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('noscript',1,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (1,'c:\\share\\sutresults\\sampletest1\\Sampletest1_001_Win_7_testvm\\provisioning','nolog.log');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (2,'SUT_Configuration',1,9,2,2);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('configureVM.bat',2,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (2,'c:\\share\\sutresults\\sampletest1\\Sampletest1_001_Win_7_testvm\\SUT_Configuration','rts.log');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (3,'TestCase01',1,9,3,3);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('TestCase01.bat',3,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (3,'c:\\share\\sutresults\\sampletest1\\Sampletest1_001_Win_7_testvm\\TestCase01','rts.log'),
(3,'c:\\share\\sutresults\\sampletest1\\Sampletest1_001_Win_7_testvm\\TestCase01','screenshot.jpg');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (4,'TestCase02',1,9,4,4);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('TestCase02.bat',4,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (4,'c:\\share\\sutresults\\sampletest1\\Sampletest1_001_Win_7_testvm\\TestCase02','rts.log'),
(4,'c:\\share\\sutresults\\sampletest1\\Sampletest1_001_Win_7_testvm\\TestCase02','screenshot.jpg');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (5,'TestCase03',1,9,5,5);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('TestCase03.bat',5,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (5,'c:\\share\\sutresults\\sampletest1\\Sampletest1_001_Win_7_testvm\\TestCase03','rts.log'),
(5,'c:\\share\\sutresults\\sampletest1\\Sampletest1_001_Win_7_testvm\\TestCase03','screenshot.jpg');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (6,'DestroySUT',1,9,6,6);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('noscript',6,1);

-- Test 1 SUT 2 Test Cases and scripts

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (7,'provisioning',2,9,1,1);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('noscript',7,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (7,'c:\\share\\sutresults\\sampletest1\\Sampletest1_002_Win_10_testvm\\provisioning','nolog.log');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (8,'SUT_Configuration',2,9,2,2);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('configureVM.bat',8,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (8,'c:\\share\\sutresults\\sampletest1\\Sampletest1_002_Win_10_testvm\\SUT_Configuration','rts.log');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (9,'TestCase01',2,9,3,3);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('TestCase01.bat',9,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (9,'c:\\share\\sutresults\\sampletest1\\Sampletest1_002_Win_10_testvm\\TestCase01','rts.log'),
(9,'c:\\share\\sutresults\\sampletest1\\Sampletest1_002_Win_10_testvm\\TestCase01','screenshot.jpg');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (10,'TestCase02',2,9,4,4);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('TestCase02.bat',10,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (10,'c:\\share\\sutresults\\sampletest1\\Sampletest1_002_Win_10_testvm\\TestCase02','rts.log'),
(10,'c:\\share\\sutresults\\sampletest1\\Sampletest1_002_Win_10_testvm\\TestCase02','screenshot.jpg');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (11,'TestCase03',2,9,5,5);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('TestCase03.bat',11,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (11,'c:\\share\\sutresults\\sampletest1\\Sampletest1_002_Win_10_testvm\\TestCase03','rts.log'),
(11,'c:\\share\\sutresults\\sampletest1\\Sampletest1_002_Win_10_testvm\\TestCase03','screenshot.jpg');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (12,'DestroySUT',2,9,6,6);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('noscript',12,1);

-- -----------------------------------------------------------------------------------------------
-- Test 2 SUT 1

INSERT INTO SUTs (ID, Name, Status_ID, Test_Suite_ID, VM_Template_ID, Hypervisor_Type_ID, Hypervisor_ID, Agent_Manager_ID, Workflow_ID, SUT_Type_ID, Log_File, IP_Address, Remote_Console_URL, Console_Active)
VALUES (3,'Sampletest2_001_Win_7_testvm',9,2,1,1,1,1,1,1,'c:\\share\\sutresults\\sampletest2\\Sampletest2_001_Win_7_testvm\\agent.log','192.168.10.197','https://192.168.2.60:9443/vsphere-client',0);

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (13,'provisioning',3,9,1,1);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('noscript',13,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (13,'c:\\share\\sutresults\\sampletest1\\Sampletest2_001_Win_7_testvm\\provisioning','nolog.log');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (14,'SUT_Configuration',3,9,2,2);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('configureVM.bat',14,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (14,'c:\\share\\sutresults\\sampletest1\\Sampletest2_001_Win_7_testvm\\SUT_Configuration','rts.log');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (15,'TestCase01',3,9,3,3);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('TestCase01.bat',15,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (15,'c:\\share\\sutresults\\sampletest1\\Sampletest2_001_Win_7_testvm\\TestCase01','rts.log'),
(15,'c:\\share\\sutresults\\sampletest1\\Sampletest2_001_Win_7_testvm\\TestCase01','screenshot.jpg');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (16,'TestCase02',3,9,4,4);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('TestCase02.bat',16,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (16,'c:\\share\\sutresults\\sampletest1\\Sampletest2_001_Win_7_testvm\\TestCase02','rts.log'),
(16,'c:\\share\\sutresults\\sampletest1\\Sampletest2_001_Win_7_testvm\\TestCase02','screenshot.jpg');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (17,'TestCase03',3,9,5,5);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('TestCase03.bat',17,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (17,'c:\\share\\sutresults\\sampletest1\\Sampletest2_001_Win_7_testvm\\TestCase03','rts.log'),
(17,'c:\\share\\sutresults\\sampletest1\\Sampletest2_001_Win_7_testvm\\TestCase03','screenshot.jpg');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (18,'DestroySUT',3,9,6,6);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('noscript',18,1);

-- Test 2 SUT 2

INSERT INTO SUTs (ID, Name, Status_ID, Test_Suite_ID, VM_Template_ID, Hypervisor_Type_ID, Hypervisor_ID, Agent_Manager_ID, Workflow_ID, SUT_Type_ID, Log_File, IP_Address, Remote_Console_URL, Console_Active)
VALUES (4,'Sampletest2_002_Win_10_testvm',9,2,2,1,2,1,1,1,'c:\\share\\sutresults\\sampletest2\\Sampletest2_001_Win_10_testvm\\agent.log','192.168.10.196','https://192.168.2.60:9443/vsphere-client',0);

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (19,'provisioning',4,9,1,1);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('noscript',19,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (19,'c:\\share\\sutresults\\sampletest2\\Sampletest2_001_Win_10_testvm\\provisioning','nolog.log');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (20,'SUT_Configuration',4,9,2,2);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('configureVM.bat',20,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (20,'c:\\share\\sutresults\\sampletest2\\Sampletest2_001_Win_10_testvm\\SUT_Configuration','rts.log');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (21,'TestCase01',4,9,3,3);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('TestCase01.bat',21,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (21,'c:\\share\\sutresults\\sampletest2\\Sampletest2_001_Win_10_testvm\\TestCase01','rts.log'),
(21,'c:\\share\\sutresults\\sampletest2\\Sampletest2_001_Win_10_testvm\\TestCase01','screenshot.jpg');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (22,'TestCase02',4,9,4,4);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('TestCase02.bat',22,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (22,'c:\\share\\sutresults\\sampletest2\\Sampletest2_001_Win_10_testvm\\TestCase02','rts.log'),
(22,'c:\\share\\sutresults\\sampletest2\\Sampletest2_001_Win_10_testvm\\TestCase02','screenshot.jpg');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (23,'TestCase03',4,9,5,5);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('TestCase03.bat',23,1);

INSERT INTO TEST_CASE_LOG_FILES (Test_Case_ID, Log_Path, Log_File_Name)
VALUES (23,'c:\\share\\sutresults\\sampletest2\\Sampletest2_001_Win_10_testvm\\TestCase03','rts.log'),
(23,'c:\\share\\sutresults\\sampletest2\\Sampletest2_001_Win_10_testvm\\TestCase03','screenshot.jpg');

INSERT INTO TEST_CASES (ID, Name, SUT_ID, STATUS_ID, RESULT_ID, Order_Index)
VALUES (24,'DestroySUT',4,9,6,6);

INSERT INTO Test_Case_Scripts(Script_Path, Test_Case_ID, Order_Index)
VALUES ('noscript',24,1);
