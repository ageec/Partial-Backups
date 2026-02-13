import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, publish, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import selections from '@salesforce/messageChannel/UserListMessageChannel__c';
import recordSet from '@salesforce/messageChannel/ConstituentQueryExclusions__c';

export default class ConstituentQueryExclusionsOutput extends LightningElement {
  commTypeValue;
  solicitationValue;
  householdsValue;
  invitationValue;
  outputValue;
  deceasedValue;
  inactiveValue;
  lostValue;
  doNotMailValue;
  doNotContactValue;
  doNotInviteValue;
  doNotSolicitValue;
  doNotSolicitByMailValue;
  doNotSolicitByEmailValue;
  emailOptOutValue;
  currStudentValue;
  trusteeValue;
  _selectedFields = [];
  _selectedLabels = [];
  commTypeSelected = false;
  solicitationValueSelected = false;
  invitationValueSelected = false;
  householdsValueSelected = false;
  showExclusions = false;
  exclusionsApplied = false;
  allExclusions = false;
  mailExclusions = false;
  emailExclusions = false;
  mailSolicitExclusions = false;
  emailSolicitExclusions = false;
  solicitExclusions = false;
  inviteExclusions = false;
  mailMergeSelected = false;
  emailMergeSelected = false;
  standardAccountSelected = false;
  standardContactSelected = false;
  queryName;
  queryDescription;
  showSubmitButtons = false;
  showExclusionsOutput = false;
  mailMergeFields = ['AQB__MailingName__c','AQB__MailingNameLineTwo__c','AQB__Greeting__c',
    'Contact.AQB__Greeting__c','ACS.Spouse.Contact.AQB__Greeting__c','AQB__AccountMailingStreetLineOne__c',
    'AQB__AccountMailingStreetLineTwo__c','AQB__AccountMailingStreetLineThree__c','BillingCity',
    'BillingState','BillingPostalCode','BillingCountry','ARCH_Target_Market__c',
    'ARCH_Metro_Area__c','ARCH_Territory__c','Contact.ARCH_Sort_Name__c','ARCH_Account_ID__c',
    'Contact.ARCH_Contact_ID__c','ACS.Contact_Recipe.Spouse.ARCH_Contact_ID__c',
    'ARCH_Total_Pledge_and_Grant_Balance__c','GivingAgg.CFYAnnualFundTotal','CFYCenturyClubYesNo','GivingAgg.CFYTotal',
    'ACS.IsCurrentStudent','Contact.AQB__Deceased__c',
    'ACS.Contact_Recipe.Spouse.AQB__Deceased__c','ARCH_Do_Not_Call__c','AQB__DoNotContact__c',
    'ARCH_Do_Not_Mail__c','AQB__DoNotSolicit__c','ARCH_Do_Not_Solicit_by_Email__c',
    'ARCH_Do_Not_Solicit_by_Mail__c','ARCH_Do_Not_Solicit_by_Phone__c','ARCH_Do_Not_Visit__c',
    'ARCH_Email_Opt_Out__c','AQC_Lost__c','Type','ACS.Secondary_Account_Types','Contact.AQC_Special_Handling__c',
    'TributeOnlyDonor','ACS.IsTrustee','ACS.Contact_Recipe.IsSpouseTrustee'];

  emailMergeFields = ['Name','Contact.Name','Contact.AQB__Greeting__c','Contact.Email','Contact.ARCH_Sort_Name__c',
    'ARCH_Account_ID__c','Contact.ARCH_Contact_ID__c','ARCH_Total_Pledge_and_Grant_Balance__c','GivingAgg.CFYAnnualFundTotal',
    'CFYCenturyClubYesNo','GivingAgg.CFYTotal','ACS.IsCurrentStudent',
    'Contact.AQB__Deceased__c','Contact.DoNotCall','Contact.AQB__DoNotContact__c',
    'Contact.ARCH_Do_Not_Mail__c','Contact.AQB__DoNotSolicit__c','Contact.ARCH_Do_Not_Solicit_by_Email__c',
    'Contact.ARCH_Do_Not_Solicit_by_Mail__c','Contact.ARCH_Do_Not_Solicit_by_Phone__c','Contact.ARCH_Do_Not_Visit__c',
    'Contact.HasOptedOutOfEmail','BillingCountry','Contact.ARCH_Lost__c','ACS.Secondary_Contact_Types','Contact.AQC_Special_Handling__c',
    'TributeOnlyDonor','ACS.IsTrustee','ACS.Contact_Recipe.IsSpouseTrustee'];

  standardAccountFields = ['Contact.ARCH_Sort_Name__c','ARCH_Account_ID__c','Contact.LastName',
    'Contact.FirstName','Contact.MiddleName','Contact.Salutation','Contact.Suffix',
    'AQB__MailingName__c','AQB__MailingNameLineTwo__c','AQB__Greeting__c','Type','ACS.Secondary_Account_Types',
    'Contact.AQB__InstitutionalSuffix__c','ACS.Contact_Recipe.Spouse.AQB__InstitutionalSuffix__c',
    'AQB__AccountMailingStreetLineOne__c','AQB__AccountMailingStreetLineTwo__c','AQB__AccountMailingStreetLineThree__c',
    'BillingCity','BillingState','BillingPostalCode','BillingCountry',
    'ARCH_Metro_Area__c','ARCH_Target_Market__c','ARCH_Total_Gifts_and_Pledges_all_types__c','ARCH_Total_Dollars_Received__c',
    'ARCH_Total_Pledge_and_Grant_Balance__c','AQB__TotalYearsGiven__c','CFYLoyaltySociety.AQB__Count__c',
    'AQB__ProspectStatus__c','AQB__ProspectStatusDate__c','ACS.Contact_Recipe.Last_Substantive_Activity.Activity_Report.AQB__Subject__c',
    'LifeEliot.AQB__GivingLevel__c','CFYGivingClubs.CFYGivingClubList','CFYGivingClubs.CFYGivingLevelList',
    'PFYGivingClubs.PFYGivingClubList','PFYGivingClubs.PFYGivingLevelList',
    'AQB__Capacity__c','ACS.Relationship_Manager.User.Name','AQC_Lost__c','Contact.AQB__Deceased__c',
    'AQB__DoNotContact__c','ARCH_Do_Not_Mail__c','ARCH_Do_Not_Call__c','ARCH_Email_Opt_Out__c','ARCH_Do_Not_Visit__c','AQB__DoNotSolicit__c',
    'ARCH_Do_Not_Solicit_by_Mail__c','ARCH_Do_Not_Solicit_by_Email__c','ARCH_Do_Not_Solicit_by_Phone__c',
    'Contact.AQC_Special_Handling__c'];

  standardContactFields = ['Contact.ARCH_Sort_Name__c','ARCH_Account_ID__c','Contact.ARCH_Contact_ID__c',
    'Contact.ARCH_ContactMailingName__c','Contact.AQB__Greeting__c','Contact.AQB__Type__c','ARCH_Total_Pledge_and_Grant_Balance__c',
    'ACS.Secondary_Contact_Types','Contact.Birthdate','ACS.Contact_Recipe.Spouse.ARCH_ContactMailingName__c',
    'Contact.AQB__InstitutionalSuffix__c','AQB__AccountMailingStreetLineOne__c','AQB__AccountMailingStreetLineTwo__c',
    'AQB__AccountMailingStreetLineThree__c','BillingCity','BillingState','BillingPostalCode',
    'BillingCountry','Contact.Phone','Contact.HomePhone','Contact.MobilePhone','Contact.Email','ARCH_Metro_Area__c','ARCH_Target_Market__c',
    'ACS.Employment.AQB__EmployerNameDisplay__c','ACS.Employment.AQB__Title__c','ARCH_Total_Gifts_and_Pledges_all_types__c',
    'ARCH_Total_Dollars_Received__c','AQB__TotalYearsGiven__c','CFYLoyaltySociety.AQB__Count__c',
    'CFYCenturyClubYesNo','GivingAgg.CFYTotal','ACS.IsCurrentStudent',
    'Contact.AQB__PrimaryGiftRecognitionCredit_Percent__c','Contact.AQB__SecondaryGiftRecognitionCreditPercent__c',
    'LifeEliot.AQB__GivingLevel__c','CFYGivingClubs.CFYGivingClubList','AQB__Capacity__c','ACS.Relationship_Manager.User.Name'];

  @wire(MessageContext)
  messageContext;

  get commTypeOptions () {
    return [
        { label: 'I\'m sending a mailing', value: 'mail' },
        { label: 'I\'m sending an email', value: 'email' },
        { label: 'This is some other form of communication', value: 'other' },
        { label: 'This list will not be used for a communication', value: 'none' },
    ];
  }

  handleCommType (event) {
    this.commTypeValue = event.detail.value;
    this.commTypeSelected = true;
    if (this.commTypeSelected && this.solicitationValueSelected && this.invitationValueSelected && this.householdsValueSelected) {
      this.showExclusions = true;
    }
    this.allExclusions = false;
    this.mailExclusions = false;
    this.deceasedValue = false;
    this.inactiveValue = false;
    this.lostValue = false;
    this.mailSolicitExclusions = false;
    this.emailExclusions = false;
    this.inviteExclusions = false;
    if (this.commTypeValue == 'mail') {
      this.allExclusions = true;
      this.mailExclusions = true;
      this.deceasedValue = true;
      this.inactiveValue = true;
      this.lostValue = true;
      this.currStudentValue = true;
      if (this.solicitationValue == 'solicit') {
        this.mailSolicitExclusions = true;
      }
    }
    if (this.commTypeValue == 'email') {
      this.allExclusions = true;
      this.emailExclusions = true;
      if (this.solicitationValue == 'solicit') {
        this.emailSolicitExclusions = true;
      }
    }
    if (this.commTypeValue == 'invite') {
      this.allExclusions = true;
      this.doNotInviteValue = true;
      this.inviteExclusions = true;
      this.deceasedValue = true;
      this.inactiveValue = true;
    }

    if (this.commTypeValue == 'other') {
      this.allExclusions = true;
      this.deceasedValue = true;
      this.inactiveValue = true;
      this.doNotContactValue = true;
    }
  }

  get solicitationOptions () {
    return [
        { label: 'This is a solicitation', value: 'solicit' },
        { label: 'This is not a solicitation', value: 'nosolicit' },
    ];
  }

  handleSolicitation (event) {
    this.solicitationValue = event.detail.value;
    this.solicitationValueSelected = true;
    this.mailSolicitExclusions = false;
    this.emailSolicitExclusions = false;
    this.solicitExclusions = false;
    if (this.commTypeSelected && this.solicitationValueSelected && this.invitationValueSelected && this.householdsValueSelected) {
      this.showExclusions = true;
    }
    if (this.commTypeValue == 'mail') {
      this.mailExclusions = true;
      if (this.solicitationValue == 'solicit') {
        this.mailSolicitExclusions = true;
      }
    }
    if (this.commTypeValue == 'email') {
      this.emailExclusions = true;
      if (this.solicitationValue == 'solicit') {
        this.emailSolicitExclusions = true;
      }
    }
    if (this.solicitationValue == 'solicit') {
        this.solicitExclusions = true;
        this.currStudentValue = true;
    }
  }

  get invitationOptions () {
    return [
        { label: 'This is an event invitation', value: 'invitation' },
        { label: 'This is not an event invitation', value: 'noinvitation' },
    ];
  }

  handleInvitation (event) {
    this.invitationValue = event.detail.value;
    this.invitationValueSelected = true;
    if (this.invitationValue == 'invitation') {
      this.doNotInviteValue = true;
      this.inviteExclusions = true;
    }
    if (this.invitationValue == 'noinvitation') {
      this.doNotInviteValue = false;
      this.inviteExclusions = false;
    }
    //if (this.commTypeSelected && this.solicitationValueSelected && this.invitationValueSelected && this.householdsValueSelected) {
    //  this.showExclusions = true;
    //}
  }

  get outputOptions () {
    return [
        { label: 'Comma-separated values (csv) file', value: 'csv' },
        { label: 'Excel spreadsheet (xls) file', value: 'xls' },
    ];
  }

  handleOutput (event) {
    this.outputValue = event.detail.value;
  }

  handleDeceased (event) {
    if (event.target.checked) {
      this.deceasedValue = true;
    } else {
      this.deceasedValue = false;
    }
  }

  handleLost (event) {
    if (event.target.checked) {
      this.lostValue = true;
    } else {
      this.lostValue = false;
    }
  }

  handleDoNotMail (event) {
    if (event.target.checked) {
      this.doNotMailValue = true;
    } else {
      this.doNotMailValue = false;
    }
  }

  handleDoNotContact (event) {
    if (event.target.checked) {
      this.doNotContactValue = true;
    } else {
      this.doNotContactValue = false;
    }
  }

  handleDoNotSolicit (event) {
    if (event.target.checked) {
      this.doNotSolicitValue = true;
    } else {
      this.doNotSolicitValue = false;
    }
  }

  handleDoNotSolicitByMail (event) {
    if (event.target.checked) {
      this.doNotSolicitByMailValue = true;
  } else {
      this.doNotSolicitByMailValue = false;
  }
  }

  handleDoNotSolicitByEmail (event) {
    if (event.target.checked) {
      this.doNotSolicitByEmailValue = true;
    } else {
      this.doNotSolicitByEmailValue = false;
    }
  }

  handleEmailOptOuts (event) {
    if (event.target.checked) {
      this.emailOptOutValue = true;
    } else {
      this.emailOptOutValue = false;
    }
  }

  handleDoNotInvite (event) {
    if (event.target.checked) {
      this.doNotInviteValue = true;
    } else {
      this.doNotInviteValue = false;
    }
  }

  handleCurrStudent (event) {
    if (event.target.checked) {
      this.currStudentValue = true;
    } else {
      this.currStudentValue = false;
    }
  }

  handleTrustee (event) {
    if (event.target.checked) {
      this.trusteeValue = true;
    } else {
      this.trusteeValue = false;
    }
  }

  get householdOptions () {
    return [
        { label: 'Yes (Output will show one Account per line)', value: 'householdyes' },
        { label: 'No (Output will show one Contact per line)', value: 'householdno' },
    ];
  }

  handleHouseholds (event) {
    if (event.detail.value == 'householdyes') {
        this.householdsValue = true;
    } else {
        this.householdsValue = false;
    }
    this.householdsValueSelected = true;
    
    if (this.commTypeSelected && this.solicitationValueSelected && this.invitationValueSelected && this.householdsValueSelected) {
      this.showExclusions = true;
    }

  }

  handleExclusions (event) {
    this.exclusionsApplied = true;
  }

  handleFormValidation () {
    let queryNameCmp = this.template.querySelector(".queryName");
    /*let commTypeCmp = this.template.querySelector(".communicationType");
    let solicitationCmp = this.template.querySelector(".solicitation");
    let inviteCmp = this.template.querySelector(".eventinvitation");
    let householdCmp = this.template.querySelector(".households");
    let outputFieldsCmp = this.template.querySelector(".outputFields");*/
    if (!queryNameCmp.value) {
      queryNameCmp.setCustomValidity('Query Name is a required field. Please provide it and then try again.');
    } else {
      queryNameCmp.setCustomValidity("");
    }
    queryNameCmp.reportValidity();
    /*if (!commTypeCmp.value) {
      commTypeCmp.setCustomValidity('You must indicate what type of communication you will be sending.');
    } else {
      commTypeCmp.setCustomValidity("");
    }
    commTypeCmp.reportValidity();
    if (!solicitationCmp.value) {
      solicitationCmp.setCustomValidity('You must indicate whether this is a solicitation.');
    } else {
      solicitationCmp.setCustomValidity("");
    }
    solicitationCmp.reportValidity();
    if (!inviteCmp.value) {
      inviteCmp.setCustomValidity('You must indicate whether this is an event invitation.');
    } else {
      inviteCmp.setCustomValidity("");
    }
    inviteCmp.reportValidity();
    if (!householdCmp.value) {
      householdCmp.setCustomValidity('You must indicate whether you wish to combine households.');
    } else {
      householdCmp.setCustomValidity("");
    }
    householdCmp.reportValidity();
    if (!outputFieldsCmp.value) {
      outputFieldsCmp.setCustomValidity('You must choose the fields you wish to include in output.');
    } else {
      outputFieldsCmp.setCustomValidity("");
    }
    outputFieldsCmp.reportValidity();*/
  }

  handleSubmit (event) {
    //this.handleFormValidation();
    let validated = true;
    if (this.queryName == null || this.queryName == undefined || this.queryName.length == 0) {
      validated = false;
      const event = new ShowToastEvent({
        title: 'Error',
        message: 'You did not provide a name for your query. Please update the Query Name field and try again.',
        variant: 'error',
        mode: 'dismissable'
      });
      this.dispatchEvent(event);
    }
    if (this.commTypeValue == null || this.commTypeValue == undefined || this.commTypeValue.length == 0) {
      validated = false;
      const event = new ShowToastEvent({
        title: 'Error',
        message: 'You did not select a communication type. Please select a communication type and try again.',
        variant: 'error',
        mode: 'dismissable'
      });
      this.dispatchEvent(event);
    }
    if (this.solicitationValue == null || this.solicitationValue == undefined || this.solicitationValue.length == 0) {
      validated = false;
      const event = new ShowToastEvent({
        title: 'Error',
        message: 'You did not indicate whether you are doing a solicitation. Please answer the solicitation question and try again.',
        variant: 'error',
        mode: 'dismissable'
      });
      this.dispatchEvent(event);
    }
    if (this.invitationValue == null || this.invitationValue == undefined || this.invitationValue.length == 0) {
      validated = false;
      const event = new ShowToastEvent({
        title: 'Error',
        message: 'You did not indicate whether you are doing an event invitation. Please answer the event invitation question and try again.',
        variant: 'error',
        mode: 'dismissable'
      });
      this.dispatchEvent(event);
    }
    if (this.outputValue == null || this.outputValue == undefined || this.outputValue.length == 0) {
      validated = false;
      const event = new ShowToastEvent({
        title: 'Error',
        message: 'You did not choose an output type. Please select an output type and try again.',
        variant: 'error',
        mode: 'dismissable'
      });
      this.dispatchEvent(event);
    }
    if (this.householdsValue == null || this.householdsValue == undefined || this.householdsValue.length == 0) {
      validated = false;
      const event = new ShowToastEvent({
        title: 'Error',
        message: 'You did not indicate whether you want to combine households. Please answer the households question and try again.',
        variant: 'error',
        mode: 'dismissable'
      });
      this.dispatchEvent(event);
    }
    if (validated) {
      try {
        const msgPayload = {communicationType: this.commTypeValue,
                            solicitationValue: this.solicitationValue,
                            excludeDeceased: this.deceasedValue,
                            excludeInactive: this.inactiveValue,
                            excludeLost: this.lostValue,
                            excludeDoNotMail: this.doNotMailValue,
                            excludeDoNotContact: this.doNotContactValue,
                            excludeDoNotSolicit: this.doNotSolicitValue,
                            excludeDoNotSolicitMail: this.doNotSolicitByMailValue,
                            excludeDoNotSolicitEmail: this.doNotSolicitByEmailValue,
                            excludeEmailOptOut: this.emailOptOutValue,
                            excludeDoNotInvite: this.doNotInviteValue,
                            excludeCurrentStudents: this.currStudentValue,
                            excludeTrustees: this.trusteeValue,
                            combineHouseholds: this.householdsValue,
                            fieldsValue: this._selectedFields,
                            fieldLabelsValue: this._selectedLabels,
                            queryNameValue: this.queryName,
                            queryDescriptionValue: this.queryDescription,
                            outputType:this.outputValue,
        };
        publish(this.messageContext, recordSet, msgPayload);
      } catch (e) {
        console.log(e);  
      }
    }
  }

  handleMailMerge (event) {
   this.mailMergeSelected = true;
   this._selectedFields = this.mailMergeFields;
   this._selectedLabels = this.mailMergeFields;
  }

  handleEmailMerge (event) {
   this.emailMergeSelected = true;
   this._selectedFields = this.emailMergeFields;
   this._selectedLabels = this.emailMergeFields;
  }

  handleStandardAccount (event) {
   this.standardAccountSelected = true;
   this._selectedFields = this.standardAccountFields;
   this._selectedLabels = this.standardAccountFields;
  }

  handleStandardContact (event) {
   this.standardContactSelected = true;
   this._selectedFields = this.standardContactFields;
   this._selectedLabels = this.standardContactFields;
  }

  get fieldOptions() {
    return [
        { label: 'Account Greeting (Account)', value: 'AQB__Greeting__c'},
        { label: 'Account Name (Account)', value: 'Name'},
        { label: 'Account Type (Account)', value: 'Type' },
        { label: 'Active Prospect Strategy Plan (Account)', value: 'ARCH_Notes_and_Comments__c' },
        { label: 'Annual Rating (Account)', value: 'AQC_Annual_Rating__c' },
        { label: 'Mailing City (Account)', value: 'BillingCity' },
        { label: 'Mailing Country (Account)', value: 'BillingCountry' },
        { label: 'Mailing State/Province (Account)', value: 'BillingState' },
        { label: 'Account Mailing Street Line One (Account)', value: 'AQB__AccountMailingStreetLineOne__c'},
        { label: 'Account Mailing Street Line Two (Account)', value: 'AQB__AccountMailingStreetLineTwo__c'},
        { label: 'Account Mailing Street Line Three (Account)', value: 'AQB__AccountMailingStreetLineThree__c'},
        { label: 'Mailing Zip/Postal Code (Account)', value: 'BillingPostalCode' },
        { label: 'Comprehensive Campaign Total Gifts and Commitments (Account)', value: 'GivingAgg.ComprehensiveCampaignTotal'},
        { label: 'Consecutive Years Given (Account)', value: 'AQB__ConsecutiveYearsGiven__c'},
        { label: 'Do Not Call (Account)', value: 'ARCH_Do_Not_Call__c'},
        { label: 'Do Not Contact (Account)', value: 'AQB__DoNotContact__c' },
        { label: 'Do Not Invite (Account)', value: 'ARCH_Do_Not_Invite__c'},
        { label: 'Do Not Mail (Account)', value: 'ARCH_Do_Not_Mail__c'},
        { label: 'Do Not Solicit (Account)', value: 'AQB__DoNotSolicit__c' },
        { label: 'Do Not Solicit by Email (Account)', value: 'ARCH_Do_Not_Solicit_by_Email__c'},
        { label: 'Do Not Solicit by Mail (Account)', value: 'ARCH_Do_Not_Solicit_by_Mail__c'},
        { label: 'Do Not Solicit by Phone (Account)', value: 'ARCH_Do_Not_Solicit_by_Phone__c'},
        { label: 'Do Not Visit (Account)', value: 'ARCH_Do_Not_Visit__c'},
        { label: 'Donor Status (Account)', value: 'ARCH_Donor_Status__c'},
        { label: 'Email Opt Out (Account)', value: 'ARCH_Email_Opt_Out__c'},
        { label: 'Estate Commitments (Account)', value: 'ARCH_Estate_Commitments__c'},
        { label: 'Interest Types (Account)', value: 'ACS.AccountInterests.AllAccountInterestTypesList'},
        { label: 'Life Income Gift (Account)', value: 'ARCH_Life_Income_Gift__c'},
        { label: 'Lost (Account)', value: 'AQC_Lost__c'},
        { label: 'Mailing Address Type (Account)', value: 'AQB__BillingAddressType__c'},
        { label: 'Mailing Name Line One (Account)', value: 'AQB__MailingName__c' },
        { label: 'Mailing Name Line Two (Account)', value: 'AQB__MailingNameLineTwo__c' },
        { label: 'Metro Area (Account)', value: 'ARCH_Metro_Area__c' },
        { label: 'Overall Account Capacity (Account)', value: 'AQB__Capacity__c' },
        { label: 'Overall Account Rating Date (Account)', value: 'AQB__OverallAccountRatingDate__c' },
        { label: 'Parent Account (Account)', value: 'ParentId'},
        { label: 'Primary Contact (Account)', value: 'AQB__PrimaryContact__c'},
        { label: 'Primary Gift Officer (Account)', value: 'ACS.Account.ARCH_PrimaryGiftOfficerName__c'},
        { label: 'Prospect Status (Account)', value: 'AQB__ProspectStatus__c' },
        { label: 'Prospect Status Date (Account)', value: 'AQB__ProspectStatusDate__c' },
        { label: 'Record Type (Account)', value: 'ARCH_Record_Type_Name__c' },
        { label: 'Relationship Manager (Account)', value: 'ACS.Relationship_Manager.User.Name' },
        { label: 'Secondary Account Types (Account)', value: 'ACS.Secondary_Account_Types'},
        { label: 'Secondary Contact (Account)', value: 'AQB__SecondaryContact__c'},
        { label: 'Student Initiative Total Gifts and Commitments (Account)', value: 'GivingAgg.SUM_StudentInitiativeAmount'},
        { label: 'Target Market (Account)', value: 'ARCH_Target_Market__c' },
        { label: 'Territory (Account)', value: 'ARCH_Territory__c' },
        { label: 'Total Bequest Balance (Account)', value: 'ARCH_Total_Bequest_Balance__c'},
        { label: 'Total Bequest Commitments (Account)', value: 'ARCH_Total_Bequest_Commitments__c'},
        { label: 'Total Dollars Received (Account)', value: 'ARCH_Total_Dollars_Received__c'},
        { label: 'Total Gifts and Pledges (all types) (Account)', value: 'ARCH_Total_Gifts_and_Pledges_all_types__c'},
        { label: 'Total Legal Gifts, Pledges, and Bequests (Account)', value: 'ARCH_Total_Legal_Gifts_and_Pledges__c'},
        { label: 'Total Legal Pledge and Grant Balance (Account)', value: 'ARCH_Total_Pledge_and_Grant_Balance__c'},
        { label: 'Total Legal Pledge and Grant Commitments (Account)', value: 'ARCH_Total_Pledge_and_Grant_Commitments__c'},
        { label: 'Total Matching Gift Payments Received (Account)', value: 'ARCH_Account_Gift_Pledges_Matching_Total__c'},
        { label: 'Total Open Opportunities (Account)', value: 'AQB__OpenOpps__c' },
        { label: 'Total Soft Credit Commitments (Account)', value: 'ARCH_Total_Soft_Credit_Commitments__c'},
        { label: 'Total Soft Credit Commitments Balance (Account)', value: 'ARCH_Total_Soft_Credit_Balance__c'},
        { label: 'Total Soft Credits Received (Account)', value: 'ARCH_Total_Soft_Credits__c'},
        { label: 'Total Years Given (Account)', value: 'AQB__TotalYearsGiven__c'},
        { label: 'ARCH Contact ID (Contact)', value: 'Contact.ARCH_Contact_ID__c' },
        { label: 'Contact Mailing Name (Contact)', value: 'Contact.ARCH_ContactMailingName__c' },
        { label: 'Contact Type (Contact)', value: 'Contact.AQB__Type__c' },
        { label: 'Deceased? (Contact)', value: 'Contact.AQB__Deceased__c' },
        { label: 'Do Not Call (Contact)', value: 'Contact.DoNotCall'},
        { label: 'Do Not Contact (Contact)', value: 'Contact.AQB__DoNotContact__c'},
        { label: 'Do Not Invite (Contact)', value: 'Contact.ARCH_Do_Not_Invite__c'},
        { label: 'Do Not Mail (Contact)', value: 'Contact.ARCH_Do_Not_Mail__c' },
        { label: 'Do Not Solicit (Contact)', value: 'Contact.AQB__DoNotSolicit__c'},
        { label: 'Do Not Solicit by Email (Contact)', value: 'Contact.ARCH_Do_Not_Solicit_by_Email__c' },
        { label: 'Do Not Solicit by Mail (Contact)', value: 'Contact.ARCH_Do_Not_Solicit_by_Mail__c' },
        { label: 'Do Not Solicit by Phone (Contact)', value: 'Contact.ARCH_Do_Not_Solicit_by_Phone__c' },
        { label: 'Do Not Visit (Contact)', value: 'Contact.ARCH_Do_Not_Visit__c'},
        { label: 'Email (Contact)', value: 'Contact.Email' },
        { label: 'Email Opt Out (Contact)', value: 'Contact.HasOptedOutOfEmail' },
        { label: 'Email Preference (Contact)', value: 'Contact.AQB__EmailPreference__c'},
        { label: 'First Name (Contact)', value: 'Contact.FirstName' },
        { label: 'Greeting (Contact)', value: 'Contact.AQB__Greeting__c'},
        { label: 'Institutional Suffix (Contact)', value: 'Contact.AQB__InstitutionalSuffix__c' },
        { label: 'Interest Types (Contact)', value: 'ACS.ContactInterests.AllContactInterestTypesList'},
        { label: 'Last Name (Contact)', value: 'Contact.LastName' },
        { label: 'Lost (Contact)', value: 'Contact.ARCH_Lost__c' },
        { label: 'Phone (Contact)', value: 'Contact.Phone' },
        { label: 'Phone Preference (Contact)', value: 'Contact.AQB__PhonePreference__c'},
        { label: 'Salesforce ID (Contact)', value: 'Contact.Id'},
        { label: 'Secondary Contact Types (Contact)', value: 'ACS.Secondary_Contact_Types' },
        { label: 'Sort Name (Contact)', value: 'Contact.ARCH_Sort_Name__c'},
        { label: 'Student Interest Groups (Contact)', value: 'ACS.Student_Interest_Group' },
        { label: 'Student Interest Types (Contact)', value: 'ACS.Interest_Type' },
        { label: 'Degree Level (Education)', value: 'ACS.Degree_Level' },
        { label: 'Degree/Diploma (Education)', value: 'ACS.Degree_Diploma' },
        { label: 'Department (Education)', value: 'ACS.Department' },
        { label: 'Graduation Year (Education)', value: 'ACS.Year' },
        { label: 'Preferred Year (Education)', value: 'ACS.Preferred_Year' },
        { label: 'School (Education)', value: 'ACS.School' },
        { label: 'Employer Name (Employment)', value: 'ACS.Employment.AQB__EmployerNameDisplay__c' },
        { label: 'Status (Employment)', value: 'ACS.Employment.AQB__Status__c' },
        { label: 'Title (Employment)', value: 'ACS.Employment.AQB__Title__c' },
        { label: 'Annual Giving Officer (Relationship Management Team)', value: 'PMTeam.PMTeam.AnnualGivingOfficer'},
        { label: 'Annual Giving Pipeline Officer (Relationship Management Team)', value: 'PMTeam.PMTeam.AnnualGivingPipelineOfficer'},
        { label: 'Corps/Founds Officer (Relationship Management Team)', value: 'PMTeam.PMTeam.CorpsFoundsOfficer'},
        { label: 'Donor Relations Officer (Relationship Management Team)', value: 'PMTeam.PMTeam.DonorRelationsOfficer'},
        { label: 'Executive Partner (Relationship Management Team)', value: 'PMTeam.PMTeam.ExecutivePartner'},
        { label: 'Handoff Officer (Relationship Management Team)', value: 'PMTeam.PMTeam.HandoffOfficer'},
        { label: 'Lead (Relationship Management Team)', value: 'PMTeam.PMTeam.Lead'},
        { label: 'Medicine Giving Officer (Relationship Management Team)', value: 'PMTeam.PMTeam.MedicineGivingOfficer'},
        { label: 'Planned Giving Officer (Relationship Management Team)', value: 'PMTeam.PMTeam.PlannedGivingOfficer'},
        { label: 'Principal Gifts Liaison (Relationship Management Team)', value: 'PMTeam.PMTeam.PrincipalGiftsLiaison'},
        { label: 'Prospect Management Consultant (Relationship Management Team)', value: 'PMTeam.PMTeam.ProspectManagementConsultant'},
        { label: 'Prospect Researcher (Relationship Management Team)', value: 'PMTeam.PMTeam.ProspectResearcher'},
        { label: 'Proxy Officer (Relationship Management Team)', value: 'PMTeam.PMTeam.ProxyOfficer'},
        { label: 'Qualifying Gift Officer (Relationship Management Team)', value: 'PMTeam.PMTeam.QualifyingGiftOfficer'},
        { label: 'Stewardship Officer (Relationship Management Team)', value: 'PMTeam.PMTeam.StewardshipOfficer'},
        { label: 'Strategy Officer (Relationship Management Team)', value: 'PMTeam.PMTeam.StrategyOfficer'},
        { label: 'Territory Partner (Relationship Management Team)', value: 'PMTeam.PMTeam.TerritoryPartner'},
        { label: 'Volunteer Manager (Relationship Management Team)', value: 'PMTeam.PMTeam.VolunteerManager'},
        { label: 'CFY Annual Fund Giving Total', value: 'GivingAgg.CFYAnnualFundTotal' },
        { label: 'CFY Eliot Giving Level', value: 'EliotStatus.CFYEliot.CFY_Giving_Level'},
        { label: 'CFY Giving Clubs', value: 'CFYGivingClubs.CFYGivingClubList' },
        { label: 'CFY Giving Total', value: 'GivingAgg.CFYTotal' },
        { label: 'CFY Loyalty Society Years', value: 'CFYLoyaltySociety.AQB__Count__c' },
        { label: 'Current Student?', value: 'ACS.IsCurrentStudent' },
        { label: 'Life Eliot Society', value: 'LifeEliotYesNo' },
        { label: 'Lifetime Annual Fund Total', value: 'GivingAgg.LifetimeAnnualFundAmount' },
        { label: 'PFY Annual Fund Giving Total', value: 'GivingAgg.PFYAnnualFundTotal' },
        { label: 'PFY Eliot Society Level', value: 'EliotStatus.PFYEliot.PFY_Giving_Level'},
        { label: 'PFY Giving Clubs', value: 'PFYGivingClubs.PFYGivingClubList' },
        { label: 'PFY Giving Total', value: 'GivingAgg.PFYTotal' },
        { label: 'PFY Loyalty Society Years', value: 'PFYLoyaltySociety.AQB__Count__c' },
        { label: 'Trustee?', value: 'ACS.IsTrustee' },
    ];
  }

  get selectedFields () {
    return this._selectedFields.length ? this._selectedFields : 'none';
  }

  handleSelectedFields (event) {
    try {
      this._selectedFields = event.detail.value;
      this._selectedLabels = this._selectedFields;
    } catch (e) {
      console.log(e);
    }
  }

  handleQueryName (event) {
    this.queryName = event.target.value;
    this.showSubmitButtons = true;
  }

  handleQueryDescription (event) {
    this.queryDescription = event.target.value;
  }

  handleMessage (message) {
    if (message.DashboardState != null)
      this.showExclusionsOutput = true;
  }

  subscribeToMessageChannel() {
      if (!this.subscription) {
        this.subscription = subscribe(
          this.messageContext,
          selections,
          (message) => this.handleMessage(message),
          { scope: APPLICATION_SCOPE },
        );
      }
    }

    unsubscribeToMessageChannel() {
      unsubscribe(this.subscription);
      this.subscription = null;
    }

    connectedCallback() {
      this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
      this.unsubscribeToMessageChannel();
    }
}