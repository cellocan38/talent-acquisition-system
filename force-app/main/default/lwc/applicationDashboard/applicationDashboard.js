import { LightningElement, track, wire } from 'lwc';
import getApplications from '@salesforce/apex/ApplicationDashboardController.getApplications';
import updateApplicationStatus from '@salesforce/apex/ApplicationDashboardController.updateApplicationStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class ApplicationDashboard extends LightningElement {
    @track selectedStatus = 'All';
    @track applications = [];
    @track isLoading = false;
    wiredResult;

    statusOptions = [
        { label: 'All', value: 'All' },
        { label: 'New', value: 'New' },
        { label: 'Screening', value: 'Screening' },
        { label: 'Interview', value: 'Interview' },
        { label: 'Offer', value: 'Offer' },
        { label: 'Hired', value: 'Hired' },
        { label: 'Rejected', value: 'Rejected' }
    ];

    columns = [
        { label: 'Application', fieldName: 'Name' },
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'Applied Date', fieldName: 'Applied_Date__c', type: 'date' },
        { type: 'action', typeAttributes: {
            rowActions: [
                { label: 'Move to Interview', name: 'interview' },
                { label: 'Move to Offer', name: 'offer' },
                { label: 'Reject', name: 'reject' }
            ]
        }}
    ];

    @wire(getApplications, { statusFilter: '$selectedStatus' })
    wiredApplications(result) {
        this.wiredResult = result;
        if (result.data) {
            this.applications = result.data;
        }
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
    }

    handleRowAction(event) {
        const action = event.detail.action.name;
        const appId = event.detail.row.Id;
        const statusMap = {
            interview: 'Interview',
            offer: 'Offer',
            reject: 'Rejected'
        };
        this.updateStatus(appId, statusMap[action]);
    }

    updateStatus(appId, newStatus) {
        this.isLoading = true;
        updateApplicationStatus({ appId, newStatus })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Status updated to ' + newStatus,
                    variant: 'success'
                }));
                return refreshApex(this.wiredResult);
            })
            .catch(err => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: err.body.message,
                    variant: 'error'
                }));
            })
            .finally(() => { this.isLoading = false; });
    }
}