import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import exportFilteredRecords from '../common/exportFilteredRecords';
import callAjaxFunction from '../common/callAjaxFunction';
import removeHrefExport from '../common/removeHrefExport';

const index = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox()

    let controller = camelize($('body').data().controller);
    exportFilteredRecords(Routes.export_filtered_records_overseers_purchase_orders_path(), 'Email sent with Filtered ' + controller.titleize() + '!')
    cancel_purchase_order();
    removeHrefExport();
    $('.datatable').on('init.dt', function (event) {
        var date = window.hasher.getParam('PO Date')
        if (date != '' && $('.bmro-date-bag').val() == ''){
            $('.bmro-date-bag').val(date).trigger('change')
        }
    });
};

const cancel_purchase_order = () => {
    $('.datatable').on('click', '.cancel-purchase-order', function (e) {
        var id = $(this).data('purchase-order-id');
        var json = {
            url: "/overseers/purchase_orders/" + id + "/cancelled_purchase_modal",
            modalId: '#cancelPurchaseOrder',
            className: '.cancellation-form-modal',
            buttonClassName: '.confirm-cancel',
            this: $(this),
            title: '',
            commentClass: '.message-required',
            redirectionLink: '/overseers/po_requests'
        }
        callAjaxFunction(json)
    })

}

export default index