import updateSummaryBox from "../common/updateSummaryBox";
import updateLogisticsOwner from "./updateLogisticsOwner"

const materialReadinessQueue = () => {
    bindSummaryBox(".summary_box");
    updateSummaryBox();
    // aggregateSummaryBox();
    updateLogisticsOwner();
};

let bindSummaryBox = (classname) => {
    $(classname).on('click', function (e) {
        // let value = $(this).data('value'); .toLowerCase()
        var keyup_event = $.Event("keyup");
        let value = $(this).find('p')[0].innerText;
        let inputField = $('.filter-list-input');

        inputField.val(value).trigger(keyup_event);
        e.preventDefault();
        return false;
    });
};

$(window).scroll(function(){
    if ($(window).scrollTop() >= 500) {
        $('.bmro-datatable-style').addClass('bmro-datatable-style-position');
        // $('nav div').addClass('visible-title');
    }
    else {
        $('bmro-datatable-style').removeClass('bmro-datatable-style-position');
        // $('nav div').removeClass('visible-title');
    }
});

let aggregateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $('.overall-status-count').html(new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusCount));
        $('.overall-status-value').html("&#8377;" + new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusValue));
    });
};

export default materialReadinessQueue