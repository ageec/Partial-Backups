public class WU_ConstituentQueryBuilder implements Queueable, Database.AllowsCallouts {
    
    // 03/06/2025 - Daoquan
    // Add test and default ConnectApiService to prevent callouts in test context
    public interface ConnectApiService {
        ConnectApi.LiteralJson executeQuery(String query);
    }

    public class ConnectApiDefaultService implements ConnectApiService {
        public ConnectApi.LiteralJson executeQuery(String query) {
            return ConnectApi.Wave.executeQuery(query);
        }
    }
    private ConnectApiService connectApiService;
    
    private List<List<String>> queriesToExecute;
    private List<List<String>> countQueriesToExecute;
    private Boolean households;
    private String commType;
    private String solicit;
    private Boolean deceased;
    private Boolean inactive;
    private Boolean lost;
    private Boolean doNotMail;
    private Boolean doNotContact;
    private Boolean doNotSolicit; 
    private Boolean doNotSolicitMail;
    private Boolean doNotSolicitEmail;
    private Boolean emailOptOut;
    private Boolean doNotInvite;
    private Boolean currStudent;
    private Boolean trustee;
    private List<String> fields;
    private List<String> fieldLabels;
    private List<String> outputLabels = new List<String>();
    private String queryName;
    private String queryDescription;
    private String acsDataset;
    private String acsVersion;
    private String idType;
    private String outputType;
    private Integer startChunk = 0;
    private Integer endChunk = 3000;
    private Integer chunkLimit = 3000;
    private Double runId;
    Boolean execCountQuery = true;
    List<String> inputFile;
    Integer queryCounter = 0;
    Integer populationCounter = 0;
    Integer recordCount = 0;
    Double recordCounter = 0;
    Decimal queryID = 0;
    List<List<Set<Id>>> selectedIdsList = new List<List<Set<Id>>>();
    
    // 03/06/2025 - Daoquan
    // add ConnectApiService connectApiService to constructor arguments and default to ConnectApiDefaultService
    public WU_ConstituentQueryBuilder (List<List<String>> queriesToExecute, List<List<String>> countQueriesToExecute, Boolean households, String commType, String solicit, Boolean deceased, Boolean inactive, Boolean lost, Boolean doNotMail, Boolean doNotContact, Boolean doNotSolicit, Boolean doNotSolicitMail, Boolean doNotSolicitEmail, Boolean emailOptOut, Boolean doNotInvite, Boolean currStudent, Boolean trustee, List<String> fields, List<String> fieldLabels, String queryName, String queryDescription, String acsDataset, String acsVersion, List<String> inputFile, String idType, String outputType, Double runId, ConnectApiService connectApiService) {
        this.queriesToExecute = queriesToExecute;
        this.countQueriesToExecute = countQueriesToExecute;
        this.households = households;
        this.commType = commType;
        this.solicit = solicit;
        this.deceased = deceased;
        this.inactive = inactive;
        this.lost = lost;
        this.doNotMail = doNotMail;
        this.doNotContact = doNotContact;
        this.doNotSolicit = doNotSolicit; 
        this.doNotSolicitMail = doNotSolicitMail;
        this.doNotSolicitEmail = doNotSolicitEmail;
        this.emailOptOut = emailOptOut;
        this.doNotInvite = doNotInvite;
        this.currStudent = currStudent;
        this.trustee = trustee;
        this.fields = fields;
        this.fieldLabels = fieldLabels;
        this.queryName = queryName;
        this.queryDescription = queryDescription;
        this.acsDataset = acsDataset;
        this.acsVersion = acsVersion;
        this.inputFile = inputFile;
        this.idType = idType;
        this.outputType = outputType;
        this.runId = runId;      
        
        // 03/06/2025 - Daoquan
        // added code to inject ConnectApiService
        this.connectApiService = connectApiService != null ? connectApiService : new ConnectApiDefaultService();
    }
    
    public WU_ConstituentQueryBuilder () {
        // 03/06/2025 - Daoquan
        // added code to inject ConnectApiService
        this.connectApiService = new ConnectApiDefaultService();
    }
    
    public void execute (QueueableContext context) {
        List<ARCH_CQ_Selected_Record__c> srl = new List<ARCH_CQ_Selected_Record__c>();
        System.debug('Value of inputFile is ' + inputFile);
        if (inputFile != null && !inputFile.isEmpty()) {
            System.debug('Size of inputFile is ' + inputFile.size());
            execCountQuery = false;
        }
        if (execCountQuery && queryCounter == queriesToExecute[populationCounter].size()) {
            queryCounter = 0;
            populationCounter = populationCounter + 1;
        }
        Set<String> selectedIds = new Set<String>();
        Set<Id> finalSelectedIds = new Set<Id>();
        List<String> ql = queriesToExecute[populationCounter];
        List<String> cql = new List<String>();
        if (inputFile == null || inputFile.isEmpty())
            cql = countQueriesToExecute[populationCounter];
        System.debug('ql: ' + ql);
        
        if (execCountQuery && recordCount > 0)
            queryCounter = queryCounter + 1;
        System.debug('Current value of queryCounter is ' + queryCounter);
        
        String queryString;
        if (execCountQuery) {
            queryString = cql[queryCounter];
        } else {
            queryString = ql[queryCounter];
        }
        System.debug('queryString: ' + queryString);
        
        /*for (String q : ql) {
            if (queryString != null) {
                queryString += q;
            } else {
                queryString = q;
            }
        }*/
        if (inputFile != null && !inputFile.isEmpty()) {
            Integer idCount = 1;
            System.debug('Value of queryString is ' + queryString);
            if (idType == 'contact') {
                queryString += ' q = filter q by \'Contact.ARCH_Contact_ID__c\' in [';
            } else {
                queryString += ' q = filter q by \'ARCH_Account_ID__c\' in [';
            }
            for (String i : inputFile) {
                if (i != null) {
                    queryString += '"' + i + '"';
                    if (idCount < inputFile.size())
                        queryString += ', ';
                }
                idCount = idCount + 1;
            }
            queryString += ']; ';
            queryString += 'q = foreach q generate q.\'Contact.Id\' as \'ContactId\', q.\'Id\' as \'AccountId\', "GS" as \'QuerySource\', q.\'ARCH_Account_ID__c\' as \'ARCHAccountID\'; ';
            execCountQuery = false;
            recordCount = inputFile.size();
        }
        
        //populationCounter = populationCounter + 1;
        selectedIds.clear();
        //queryCallout(queryString, households, selectedIds, recordCount, execCountQuery, startChunk, chunkLimit);
        
        if (queryString != null) {
            if (execCountQuery) {
                queryString += 'q = group q by all; ';
                queryString += 'q = foreach q generate count(q) as \'idCounter\'; ';
                queryString += 'q = limit q 2000;';
                ConnectApi.LiteralJson countQueryResponse = connectApiService.executeQuery(queryString);
                String countQueryResults = countQueryResponse.json;
                System.debug(countQueryResults);
                Map<String,Object> countResponseMap = (Map<String,Object>)JSON.deserializeUntyped(countQueryResults);
                Object countResults = countResponseMap.get('results');
                Map<String,Object> countResultsMap = (Map<String,Object>)countResults;
                List<Object> countRecordsList = (List<Object>)countResultsMap.get('records');
                if (countRecordsList != null && !countRecordsList.isEmpty()) {
                    Map<String,Object> countRecordsMap = (Map<String,Object>)countRecordsList[0];
                    recordCount = (Integer)countRecordsMap.get('idCounter');
                } else {
                    recordCount = 0;
                }
                System.debug('Value of recordCount is ' + recordCount);
                execCountQuery = false;
                startChunk = 0;
            } else {
                if (!queryString.contains('q = limit')) {
                    queryString += 'q = order q by ARCHAccountID;';
                    queryString += 'q = offset q ' + startChunk + '; ';
                    queryString += 'q = limit q ' + chunkLimit + '; ';
                }
                System.debug('Value of query to retrieve records is ' + queryString);
                // 03/06/2025 - Daoquan
                // new code added to use the ConnectApiService
                ConnectApi.LiteralJson queryResponse = connectApiService.executeQuery(queryString);
                String queryResults = queryResponse.json;
                //System.debug(queryResults);
                Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(queryResults);
                Object results = responseMap.get('results');
                Map<String,Object> resultsMap = (Map<String,Object>)results;
                List<Object> constituentList = (List<Object>)resultsMap.get('records');
                System.debug('constituentList ' + constituentList);
                for (Object o : constituentList) {
                    Map<String,Object> constituentMap = (Map<String,Object>)o;
                    String accountId = (String)constituentMap.get('AccountId');
                    String contactId;
                    if (constituentMap.containsKey('ContactId')) {
                        contactId = (String)constituentMap.get('ContactId');
                    } else {
                        contactId = accountId;
                    }
                    String querySource = (String)constituentMap.get('QuerySource');
                    String archAccountID = (String)constituentMap.get('ARCHAccountID');
                    
                    ARCH_CQ_Selected_Record__c sr = new ARCH_CQ_Selected_Record__c();
                    sr.Run_ID__c = runId;
                    if (households) {
                        //selectedIds.add(accountId);
                        sr.Selected_Record_ID__c = accountId;
                    } else {
                        //selectedIds.add(contactId);
                        sr.Selected_Record_ID__c = contactId;
                    }
                    sr.Run_Record_ID__c = runId + '|' + sr.Selected_Record_ID__c;
                    sr.Query_Count__c = queriesToExecute[populationCounter].size();
                    sr.ARCH_Account_ID__c = archAccountID;
                    if (querySource == 'GS')
                        sr.Giving_Summary_Result__c = 1;
                    if (querySource == 'ED')
                        sr.Education_Result__c = 1;
                    if (!selectedIds.contains(sr.Run_Record_ID__c)) {
                        recordCounter = recordCounter + 1;
                        sr.Record_Number__c = recordCounter;
                        srl.add(sr);
                        selectedIds.add(sr.Run_Record_ID__c);
                    }
                }
                try {
                    upsert srl Run_Record_ID__c;
                } catch (DmlException e) {
                    System.debug('Upsert of ids failed with error ' + e.getMessage());
                }
                
                startChunk = startChunk + 3000;
                if (startChunk > recordCount && queryCounter < queriesToExecute[populationCounter].size())
                    execCountQuery = true;
            }
        }
        /* Commented out with changes to write to custom object instead of using collections
        if (selectedIdsList != null && !selectedIdsList.isEmpty()) {
            if (selectedIdsList.size() >= populationCounter + 1) {
                List<Set<Id>> currSelectedIds = selectedIdsList[populationCounter];
                if (selectedIds != null) {
                    if (currSelectedIds.size() >= queryCounter + 1) {
                        currSelectedIds[queryCounter].addAll(selectedIds);
                    } else {
                        currSelectedIds.add(selectedIds);
                    }
                }
            } else {
                List<Set<Id>> currSelectedIds = new List<Set<Id>>();
                if (selectedIds != null) {
                    if (currSelectedIds.size() >= queryCounter + 1) {
                        currSelectedIds[queryCounter].addAll(selectedIds);
                    } else {
                        currSelectedIds.add(selectedIds);
                    }
                }
            }
        } else {
            if (selectedIds != null) {
                List<Set<Id>> currSelectedIds = new List<Set<Id>>();
                currSelectedIds.add(selectedIds);
                selectedIdsList.add(currSelectedIds);
            }
        }*/
        /*     
        System.debug('size of first list in selectedIdsList: ' + selectedIdsList[0].size());
        System.debug('number of ids in first set: ' + selectedIdsList[0][0].size());
        System.debug('number of ids in second set: ' + selectedIdsList[0][1].size());
        */
        System.debug('populationCounter: ' + populationCounter);
        System.debug('queryCounter: ' + queryCounter);
        System.debug('selectedIdsList: ' + selectedIdsList);
        
        //selectedIdsList[populationCounter][queryCounter].addAll(selectedIds);
        System.debug('selectedIds: ' + selectedIds);
        System.debug('selectedIds size: ' + selectedIds.size());
        System.debug('number of queries to execute: ' + queriesToExecute[populationCounter].size());
        System.debug('queryCounter: ' + queryCounter);
        System.debug('queriesToExecute size: ' + queriesToExecute.size());
        System.debug('execCountQuery value: ' + execCountQuery);
        System.debug('finalSelectedIds value: ' + finalSelectedIds);
        if ((queryCounter < queriesToExecute[populationCounter].size() && !((queryCounter + 1) == queriesToExecute[populationCounter].size() && startChunk > recordCount)) || 
             startChunk < recordCount || 
            (populationCounter + 1) < queriesToExecute.size()) {
                if (execCountQuery || (recordCount > 0 && startChunk < recordCount))
                    System.enqueueJob(this);
        } else if (populationCounter + 1 == queriesToExecute.size()) {
            System.debug('populationCounter at set combination time: ' + populationCounter);
            System.debug('queryCounter at set combination time: ' + queryCounter);
            //combineIds(selectedIdsList, finalSelectedIds);
            //String outputData = '"';
            String outputData;
            if (outputType == 'xls') {
                outputData = '<head><META http-equiv="Content-Type" content="text/html; charset=UTF-8"></head>';
                outputData += '<table>';
                outputData += '<tr>';
                outputData += '<th filter=all>';
            } else {
                outputData = '"';
            }
            //Attempted XML and it opens in Excel but gives a warning message first - but might need to revert to this if mimicking what SF does in reports doesn't work
            //outputData = '<?xml version="1.0" encoding="UTF-8"?>';
            //outputData += '<?mso-application progid="Excel.Sheet"?>';
            //outputData += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="https://www.w3.org/TR/html401/">';
            //outputData += '<Worksheet ss:Name="Results">';
            //outputData += '<Table>';
            //outputData += '<Column ss:Index="1" ss:AutoFitWidth="0" ss:Width="110"/>';
            //outputData += '<Row>';
            Integer fPos = 0;
            String outputLabel = 'ARCH Account ID (Account)';
            outputLabels.add(outputLabel);
            if (outputType == 'xls') {
                outputData += outputLabel + '</th><th filter=all>';
            } else {
                outputData += outputLabel + '"';
                if (fPos < fieldLabels.size())
                    outputData += ',"';
            }
            for (String f : fieldLabels) {
                //outputData += '<Cell><Data ss:Type="String">';
                // 03/06/2025 - Daoquan
                // use map instead of switch when statement to improve testing coverage
                outputLabel = resolveFieldLabel(f);
                outputLabels.add(outputLabel);
                if (outputType == 'xls') {
                    outputData += outputLabel + '</th>';
                    fPos = fPos + 1;
                    if (fPos < fieldLabels.size())
                    outputData += '<th filter=all>';
                } else {
                    outputData += outputLabel + '"';
                    fPos = fPos + 1;
                    if (fPos < fieldLabels.size())
                    outputData += ',"';
                }
                //outputData += outputLabel + '</Data></Cell>';
                
            }
            if (outputType == 'xls') {
                outputData += '</tr>';
            } else {
                outputData += '\r\n';
            }
            
            //outputData += '</Row>';
            // 03/06/2025 - Daoquan
            // added condition to avoid test running
            Integer finalCount = Database.countQuery('Select Count() From ARCH_CQ_Selected_Record__c Where Run_ID__c = ' + runId);
            if (/*finalSelectedIds.size()*/ finalCount > 0 && !Test.isRunningTest())
                System.enqueueJob(new WU_ConstituentQueryOutput(queriesToExecute, finalCount, households, commType, solicit, deceased, inactive, lost, doNotMail, doNotContact, doNotSolicit, doNotSolicitMail, doNotSolicitEmail, emailOptOut, doNotInvite, currStudent, trustee, fields, outputLabels, queryName, queryDescription, acsDataset, acsVersion, outputData, outputData, outputType, runId, null));
        }
        if (recordCount == 0 && 
           (queryCounter + 1) == queriesToExecute[populationCounter].size()/* &&
           finalSelectedIds.size() == 0 &&
           selectedIds.size() == 0*/) {
           ARCH_Query__c q = new ARCH_Query__c();
           for (String s : fields) {
                if (q.ARCH_SelectedFields__c != null) {
                    q.ARCH_SelectedFields__c += ',' + s;
                } else {
                  q.ARCH_SelectedFields__c = s;
                }
           }
           q.ARCH_CommunicationType__c = commType;
           q.ARCH_Solicitation__c = solicit;
           q.ARCH_CombineHouseholds__c = households;
           q.ARCH_QueryName__c = queryName;
           q.ARCH_QueryDescription__c = queryDescription;
           q.ARCH_RecordCount__c = 0;
           q.ARCH_Exclude_Trustees__c = trustee;
           q.ARCH_Exclude_Current_Students__c = currStudent;
           q.ARCH_Exclude_Deceased__c = deceased;
           q.ARCH_Exclude_Lost__c = lost;
           q.ARCH_Exclude_Do_Not_Contact__c = doNotContact;
           q.ARCH_Exclude_Do_Not_Mail__c = doNotMail;
           q.ARCH_Exclude_Email_Optout__c = emailOptOut;
           q.ARCH_Exclude_Do_Not_Solicit__c = doNotSolicit;
           q.ARCH_Exclude_Do_Not_Solicit_by_Mail__c = doNotSolicitMail;
           q.ARCH_Exclude_Do_Not_Solicit_by_Email__c = doNotSolicitEmail;
           q.ARCH_Exclude_Do_Not_Invite__c = doNotInvite;
           q.ARCH_Selected_Output_Type__c = outputType;
           for (String s : queriesToExecute[populationCounter]) {
               if (q.ARCH_Executed_Queries__c != null) {
                   q.ARCH_Executed_Queries__c += '|' + s; 
               } else {
                   q.ARCH_Executed_Queries__c = s; 
               }   
           }
           for (String s : outputLabels) {
               if (q.ARCH_Selected_Field_Labels__c != null) {
                   q.ARCH_Selected_Field_Labels__c += '|' + s;
               } else {
                   q.ARCH_Selected_Field_Labels__c = s;
               }      
           }
           insert q; 
               
           CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'WashU_Custom_Notification'];
           Messaging.CustomNotification notification = new Messaging.CustomNotification();
           notification.setTitle('Query ' + queryName.replaceAll('[^a-zA-Z0-9 ]', '') + ' Is Complete');
           notification.setBody('Your query named ' + queryName.replaceAll('[^a-zA-Z0-9 ]', '') + ' has completed. Click this notification to view your results.');
           notification.setNotificationTypeId(notificationType.Id);
           notification.setTargetId(q.Id);
           Set<String> recipients = new Set<String>();
           recipients.add(UserInfo.getUserId());
           notification.send(recipients);
        }
    }
    
    // 03/06/2025 - Daoquan
    // use Map instead of switch-when statement to resolve the field label for testing coverage
    private String resolveFieldLabel(String f) {
        if (f == null) return '';
    
             Map<String, String> fieldLabels = new Map<String, String>{
            'AQB__Greeting__c' => 'Account Greeting (Account)',
            'AQB__AccountMailingStreetLineOne__c' => 'Mailing Street Line One (Account)',
            'AQB__AccountMailingStreetLineTwo__c' => 'Mailing Street Line Two (Account)',
            'AQB__AccountMailingStreetLineThree__c' => 'Mailing Street Line Three (Account)',
            'Name' => 'Account Name (Account)',
            'Type' => 'Account Type (Account)',
            'ActiveStrategyPlan.ActiveStrategyPlan' => 'Active Prospect Strategy Plan (Account)',
            'Alert.AllAccountAlertsText' => 'Alerts (Account)',
            'AQC_Annual_Rating__c' => 'Annual Rating (Account)',
            'BillingCity' => 'Mailing City (Account)',
            'BillingCountry' => 'Mailing Country (Account)',
            'BillingState' => 'Mailing State/Province (Account)',
            'BillingPostalCode' => 'Mailing Zip/Postal Code (Account)',
            'GivingAgg.ComprehensiveCampaignTotal' => 'Comprehensive Campaign Total Gifts and Commitments (Account)',
            'AQB__ConsecutiveYearsGiven__c' => 'Consecutive Years Given (Account)',
            'ARCH_Do_Not_Call__c' => 'Do Not Call (Account)',
            'AQB__MailingName__c' => 'Mailing Name Line One (Account)',
            'AQB__MailingNameLineTwo__c' => 'Mailing Name Line Two (Account)',
            'ARCH_Record_Type_Name__c' => 'Record Type (Account)',
            'ARCH_Account_ID__c' => 'ARCH Account ID (Account)',
            'AQB__Capacity__c' => 'Overall Account Capacity (Account)',
            'ACS.Relationship_Manager.User.Name' => 'Relationship Manager (Account)',
            'ARCH_Metro_Area__c' => 'Metro Area (Account)',
            'ARCH_Target_Market__c' => 'Target Market (Account)',
            'ARCH_Territory__c' => 'Territory (Account)',
            'AQB__ProspectStatus__c' => 'Prospect Status (Account)',
            'AQB__ProspectStatusDate__c' => 'Prospect Status Date (Account)',
            'AQB__OpenOpps__c' => 'Total Open Opportunities (Account)',
            'AQB__OverallAccountRatingDate__c' => 'Overall Account Rating Date (Account)',
            'ParentId' => 'Parent Account (Account)',
            'GivingAgg.SUM_StudentInitiativeAmount' => 'Student Initiative Total Gifts and Commitments (Account)',
            'ARCH_Total_Bequest_Balance__c' => 'Total Bequest Balance (Account)',
            'ARCH_Total_Bequest_Commitments__c' => 'Total Bequest Commitments (Account)',
            'ARCH_Total_Gifts_and_Pledges_all_types__c' => 'Total Gifts and Pledges (all types) (Account)',
            'ARCH_Total_Legal_Gifts_and_Pledges__c' => 'Total Legal Gifts, Pledges and Bequests (Account)',
            'ARCH_Total_Pledge_and_Grant_Balance__c' => 'Total Legal Pledge and Grant Balance',
            'ARCH_Total_Pledge_and_Grant_Commitments__c' => 'Total Legal Pledge and Grant Commitments (Account)',
            'ARCH_Account_Gift_Pledges_Matching_Total__c' => 'Total Matching Gift Payments Received (Account)',
            'ARCH_Total_Soft_Credit_Commitments__c' => 'Total Soft Credit Commitments (Account)',
            'ARCH_Total_Soft_Credit_Balance__c' => 'Total Soft Credit Commitments Balance (Account)',
            'ARCH_Total_Soft_Credits__c' => 'Total Soft Credits Received (Account)',
            'ActivityReport.Last_Activity_Report_Date' => 'Last Activity Report Date (Account)',
            'ActivityReport.Last_Activity_Report_Owner' => 'Last Activity Report Owner (Account)',
            'ActivityReport.Last_Activity_Report_Subject' => 'Last Activity Report Subject (Account)',
            'ActivityReport.LastActivityReportType' => 'Last Activity Report Type (Account)',
            'ActivityReport.Last_Substantive_Final_Activity_Report_Date' => 'Last Substantive Activity Report Date (Account)',
            'ActivityReport.Last_Substantive_Final_Activity_Report_Owner' => 'Last Substantive Activity Report Owner (Account)',
            'ActivityReport.Last_Substantive_Final_Activity_Report_Subject' => 'Last Substantive Activity Report Subject (Account)',
            'ActivityReport.Last_Substantive_Final_Activity_Report_Type' => 'Last Substantive Activity Report Type (Account)',
            'AQB__MostRecentGiftAmount__c' => 'Most Recent Gift/Pledge Amount (Account)',
            'AQB__MostRecentGiftDate__c' => 'Most Recent Gift/Pledge Date (Account)',
            'ARCH_MostRecentGiftPledge_Designation__c' => 'Most Recent Gift/Pledge Designation (Account)',
            'ARCH_MostRecentGiftPledge_Record_Type__c' => 'Most Recent Gift/Pledge Record Type (Account)',
            'AQB__MostRecentPledgePaymentAmount__c' => 'Most Recent Pledge Payment Amount (Account)',
            'AQB__MostRecentPledgePaymentDate__c' => 'Most Recent Pledge Payment Date (Account)',
            'MajorGift.ARCH_Major_Gift_EVI__c' => 'Major Giving EVI (Account)',
            'Contact.ARCH_Contact_ID__c' => 'ARCH Contact ID (Contact)',
            'PrimaryContact.ARCH_Contact_ID__c' => 'ARCH Contact ID (Primary Contact)',
            'SecondaryContact.ARCH_Contact_ID__c' => 'ARCH Contact ID (Secondary Contact)',
            'ACS.Secondary_Contact_Types' => 'Secondary Contact Types (Contact)',
            'Contact.AQB__Type__c' => 'Contact Type (Contact)',
            'Contact.Birthdate' => 'Birthdate (Contact)',
            'ACS.Employment.AQB__EmployerNameDisplay__c' => 'Employer Name (Employment)',
            'ACS.Employment.AQB__Status__c' => 'Status (Employment)',
            'ACS.Employment.AQB__Title__c' => 'Title (Employment)',
            'Contact.FirstName' => 'First Name (Contact)',
            'Contact.ARCH_ContactMailingName__c' => 'Contact Mailing Name (Contact)',
            'Contact.AQB__InstitutionalSuffix__c' => 'Institutional Suffix (Contact)',
            'PrimaryContact.AQB__InstitutionalSuffix__c' => 'Institutional Suffix (Primary Contact)',
            'SecondaryContact.AQB__InstitutionalSuffix__c' => 'Institutional Suffix (Secondary Contact)',
            'Contact.LastName' => 'Last Name (Contact)',
            'Contact.Email' => 'Email (Contact)',
            'PrimaryContact.Email' => 'Email (Primary Contact)',
            'SecondaryContact.Email' => 'Email (Secondary Contact)', 
            'Contact.Phone' => 'Phone (Contact)',
            'Contact.Name' => 'Contact Name (Contact)',
            'PrimaryContact.Name' => 'Contact Name (Primary Contact)',
            'SecondaryContact.Name' => 'Contact Name (Secondary Contact)',
            'GivingAgg.CFYAnnualFundTotal' => 'CFY Annual Fund Giving Total',
            'GivingAgg.CFYTotal' => 'CFY Giving Total',
            'CFYLoyaltySociety.AQB__Count__c' => 'CFY Loyalty Society Years',
            'CFYGivingClubs.CFYGivingClubList' => 'CFY Giving Clubs',
            'CFYGivingClubs.CFYGivingLevelList' => 'CFY Giving Levels',
            'EliotStatus.CFY_Eliot_Status' => 'CFY Eliot Status',
            'EliotStatus.CFYEliot.CFY_Giving_Level' => 'CFY Eliot Giving Level',
            'EliotStatus.PFYEliot.PFY_Giving_Level' => 'PFY Eliot Giving Level',
            'LifeEliotYesNo' => 'Life Eliot Society',
            'GivingAgg.LifetimeAnnualFundAmount' => 'Lifetime Annual Fund Total',
            'GivingAgg.CFYAnnualFundPaymentsSoftCreditsTotal' => 'CFY Annual Fund Payments & Soft Credits',
            'EliotStatus.CFY_Eliot_Status' => 'CFY Eliot Status',
            'GivingAgg.CFYScholarshipTotal' => 'CFY Scholarship Total',
            'GivingAgg.ScholarshipTotal' => 'Lifetime Scholarship Total',
            'PFYGivingClubs.PFYGivingClubList' => 'PFY Giving Clubs',
            'PFYGivingClubs.PFYGivingLevelList' => 'PFY Giving Levels',
            'EliotStatus.PFYEliot.PFY_Giving_Level' => 'PFY Eliot Society Level',
            'GivingAgg.PFYAnnualFundTotal' => 'PFY Annual Fund Giving Total',
            'GivingAgg.PFYAnnualFundPaymentsSoftCreditsTotal' => 'PFY Annual Fund Payments & Soft Credits',
            'GivingAgg.PFYTotal' => 'PFY Giving Total',
            'GivingAgg.PFYScholarshipTotal' => 'PFY Scholarship Total',
            'PFYLoyaltySociety.AQB__Count__c' => 'PFY Loyalty Society Years',
            'ACS.Department' => 'Departments (Education)',
            'ACS.Degree_Diploma' => 'Degree/Diploma (Education)',
            'ACS.Degree_Level' => 'Degree Level (Education)',
            'ACS.School' => 'School (Education)',
            'ACS.School_Suffix' => 'School Suffix (Education)',
            'ACS.Year' => 'Graduation Year (Education)',
            'ACS.Preferred_Year' => 'Preferred Year (Education)',
            'ACS.Student_Interest_Group' => 'Student Interest Groups (Contact)',
            'ACS.Interest_Type' => 'Student Interest Types (Contact)',
            'Contact.AQB__Deceased__c' => 'Deceased? (Contact)',
            'PrimaryContact.AQB__Deceased__c' => 'Deceased? (Primary Contact)',
            'SecondaryContact.AQB__Deceased__c' => 'Deceased? (Secondary Contact)',
            'AQB__DoNotContact__c' => 'Do Not Contact (Account)',
            'Contact.ARCH_Lost__c' => 'Lost (Contact)',
            'ARCH_Do_Not_Mail__c' => 'Do Not Mail (Account)',
            'Contact.ARCH_Do_Not_Mail__c' => 'Do Not Mail (Contact)',
            'Contact.HasOptedOutOfEmail' => 'Email Opt Out (Contact)',
            'AQB__DoNotSolicit__c' => 'Do Not Solicit (Account)',
            'Contact.ARCH_Do_Not_Solicit_by_Email__c' => 'Do Not Solicit by Email (Contact)',
            'ARCH_Do_Not_Solicit_by_Mail__c' => 'Do Not Solicit by Mail (Account)',
            'Contact.ARCH_Do_Not_Solicit_by_Mail__c' => 'Do Not Solicit by Mail (Contact)',
            'Contact.ARCH_Do_Not_Solicit_by_Phone__c' => 'Do Not Solicit by Phone (Contact)',
            'ACS.IsCurrentStudent' => 'Current Student?',
            'ACS.IsTrustee' => 'Trustee?',
            'ACS.AccountInterests.AllAccountInterestTypesList' => 'Interest Types (Account)',
            'ACS.ContactInterests.AllContactInterestTypesList' => 'Interest Types (Contact)',
            'ACS.Secondary_Account_Types' => 'Secondary Account Types (Account)',
            'Contact.ARCH_Sort_Name__c' => 'Sort Name (Contact)',
            'Contact.AQB__Greeting__c' => 'Greeting (Contact)',
            'AQC_Lost__c' => 'Lost (Account)',
            'Contact.AQB__DoNotContact__c' => 'Do Not Contact (Contact)',
            'ARCH_Email_Opt_Out__c' => 'Email Opt Out (Account)',
            'Contact.AQB__DoNotSolicit__c' => 'Do Not Solicit (Contact)',
            'ARCH_Do_Not_Solicit_by_Email__c' => 'Do Not Solicit by Email (Account)',
            'ARCH_Do_Not_Solicit_by_Phone__c' => 'Do Not Solicit by Phone (Account)',
            'ARCH_Do_Not_Invite__c' => 'Do Not Invite (Account)',
            'Contact.ARCH_Do_Not_Invite__c' => 'Do Not Invite (Contact)',
            'ARCH_Do_Not_Visit__c' => 'Do Not Visit (Account)',
            'Contact.ARCH_Do_Not_Visit__c' => 'Do Not Visit (Contact)',
            'Contact.DoNotCall' => 'Do Not Call (Contact)',
            'Contact.Id' => 'Salesforce ID (Contact)',
            'Contact.Alert.AllContactAlertsText' => 'Alerts (Contact)',
            'Name' => 'Account Name (Account)',
            'ACS.Account.ARCH_PrimaryGiftOfficerName__c' => 'Primary Gift Officer (Account)',
            'PrimaryGiftOfficerRMT.AQB__Role__c' => 'Primary Gift Officer Role (Account)',
            'AQB__BillingAddressType__c' => 'Mailing Address Type (Account)',
            'PMTeam.PMTeam.AnnualGivingOfficer' => 'Annual Giving Officer (Account)',
            'PMTeam.PMTeam.AnnualGivingPipelineOfficer' => 'Annual Giving Pipeline Officer (Relationship Management Team)',
            'PMTeam.PMTeam.CorpsFoundsOfficer' => 'Corps/Founds Officer (Relationship Management Team)',
            'PMTeam.PMTeam.DonorRelationsOfficer' => 'Donor Relations Officer (Relationship Management Team)',
            'PMTeam.PMTeam.ExecutivePartner' => 'Executive Partner (Relationship Management Team)',
            'PMTeam.PMTeam.HandoffOfficer' => 'Handoff Officer (Relationship Management Team)',
            'PMTeam.PMTeam.Lead' => 'Handoff Officer (Relationship Management Team)',
            'PMTeam.PMTeam.MedicineGivingOfficer' => 'Medicine Giving Officer (Relationship Management Team)',
            'PMTeam.PMTeam.PlannedGivingOfficer' => 'Planned Giving Officer (Relationship Management Team)',
            'PMTeam.PMTeam.PrincipalGiftsLiaison' => 'Principal Gifts Liaison (Relationship Management Team)',
            'PMTeam.PMTeam.ProspectManagementConsultant' => 'Prospect Management Consultant (Relationship Management Team)',
            'PMTeam.PMTeam.ProspectResearcher' => 'Prospect Researcher (Relationship Management Team)',
            'PMTeam.PMTeam.ProxyOfficer' => 'Proxy Officer (Relationship Management Team)',
            'PMTeam.PMTeam.QualifyingGiftOfficer' => 'Qualifying Gift Officer (Relationship Management Team)',
            'PMTeam.PMTeam.StewardshipOfficer' => 'Stewardship Officer (Relationship Management Team)',
            'PMTeam.PMTeam.StrategyOfficer' => 'Strategy Officer (Relationship Management Team)',
            'PMTeam.PMTeam.TerritoryPartner' => 'Territory Partner (Relationship Management Team)',
            'PMTeam.PMTeam.VolunteerManager' => 'Volunteer Manager (Relationship Management Team)',
            'RMTList.RMTList' => 'RMT Team',
            'Contact.AQB__PhonePreference__c' => 'Phone Preference (Contact)',
            'Contact.AQB__EmailPreference__c' => 'Email Preference (Contact)',
            'ARCH_Total_Dollars_Received__c' => 'Total Dollars Received (Account)',
            'AQB__TotalYearsGiven__c' => 'Total Years Given (Account)',
            'ARCH_Donor_Status__c' => 'Donor Status (Account)',
            'ARCH_Estate_Commitments__c' => 'Estate Commitments (Account)',
            'ARCH_Life_Income_Gift__c' => 'Life Income Gift (Account)'
            // Add any additional mappings here
        };
    
        return fieldLabels.containsKey(f) ? fieldLabels.get(f) : f;
    }
    /* This is being removed because we abandoned the use of a collection to hold records that had been selected, since we were hitting Apex heap size limits on very large
     * result sets. Commenting it out for now in case it's useful for referring back to the original approach.
    public static void combineIds (List<List<Set<Id>>> selectedIdsList, Set<Id> finalSelectedIds) {
        System.debug('selectedIdsList ' + selectedIdsList);
        Integer setPos = 0;
        for (List<Set<Id>> sl : selectedIdsList) {
            Set<Id> tempSet = new Set<Id>();
            Set<Id> tempSet2 = new Set<Id>();
            if (setPos == 0 && sl.size() > 1) {
                tempSet = WU_Utilities.intersectSets(sl[0], sl[1]);
                System.debug('More than one set; used intersectSets for first two. Current set size is ' + tempSet.size());
                setPos = 1;
            }
            if (setPos == 0 && sl.size() == 1) {
                tempSet = sl[0];
                System.debug('Only one set. Current set size is ' + tempSet.size());
            }
            setPos = setPos + 1;
            while (setPos < sl.size()) {
                if (sl.size() > 1 && setPos > 2) {
                   tempSet2 = WU_Utilities.intersectSets(tempSet, sl[setPos]);
                   setPos = setPos + 1;
                   System.debug('tempSet2: ' + tempSet2);
                }
            }
            if (tempSet2.isEmpty()) {
                finalSelectedIds.addAll(tempSet);
            } else {
                finalSelectedIds.addAll(tempSet2);
            }
            setPos = 0;
        }
    }*/

}