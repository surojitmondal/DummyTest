import { LightningElement, wire, track } from 'lwc';
import getLeadOptyConversionData from '@salesforce/apex/DataTableController.getLeadOptyConversionData';

const columns = [
    {
        label: 'Owner',
        fieldName: 'OwnerName',
        sortable: "true"
    }, {
        label: 'Total Leads',
        fieldName: 'TotalLeads',
        type: 'number',
        sortable: "true"
    }, {
        label: 'Total Opps.',
        fieldName: 'TotalOpps',
        type: 'number',
        sortable: "true"
    },
    {
        label: 'Conv Rate',
        fieldName: 'ConvRate',
        type: 'percent',
        sortable: "true"
    },
    {
        label: 'Max Created Date (Opp)',
        fieldName: 'MaxCreatedDateOpp',
        type: 'date',
        sortable: "true"
    },
    {
        label: 'Total Val (Opp)',
        fieldName: 'TotalValOpp',
        type: 'currency',
        sortable: "true"
    }
];
export default class CountDataTable extends LightningElement {
    dataLoaded;
    loader = false;
    error = null;

    @track data = [];
    @track columns = columns;
    sortBy = 'OwnerName';
    sortDirection = 'asc';
    startDate;
    endDate;

    connectedCallback() {
        let startDate = new Date();
        startDate.setDate(startDate.getDate() - 31);
        this.startDate = startDate.toISOString();
        this.endDate = new Date().toISOString();
    }

    validateDate() {
        let startDate = this.template.querySelector('[data-id="startDate"]');
        let endDate = this.template.querySelector('[data-id="endDate"]');
        if (!startDate?.value || !endDate?.value) {
            this.error = "Dates cannot be emtpy";
            return false;
        }
        else if (new Date(startDate.value) > new Date(endDate.value)) {
            this.error = "Start date cannot be greater than the end date";
            return false;
        }
        else if (parseInt((new Date(endDate.value) - new Date(startDate.value)) / (1000 * 60 * 60 * 24), 10) > 31) {
            this.error = "Difference between start and end date shouldn't be greater than 31";
            return false;
        }

        this.error = "";
        return true;
    }

    handleSearch() {
        if (this.validateDate()) {
            this.loader = true;
            getLeadOptyConversionData({ startDate: this.startDate, endDate: this.endDate })
                .then(result => {
                    if (result) {
                        this.data = JSON.parse(result);
                        this.sortAccountData(this.sortBy, this.sortDirection);
                    }
                    this.loader = false;
                })
                .catch(error => {
                    this.loader = false;
                    this.error = error;
                });
        }
    }

    //display no records
    get isDisplayNoRecords() {
        var isDisplay = true;
        if (this.data) {
            if (this.data.length == 0) {
                isDisplay = true;
            } else {
                isDisplay = false;
            }
        }
        return isDisplay;
    }

    handleSortAccountData(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortAccountData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortAccountData(fieldname, direction) {

        let parseData = JSON.parse(JSON.stringify(this.data));

        let keyValue = (a) => {
            return a[fieldname];
        };

        let isReverse = direction === 'asc' ? 1 : -1;

        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';

            return isReverse * ((x > y) - (y > x));
        });

        this.data = parseData;

    }

}