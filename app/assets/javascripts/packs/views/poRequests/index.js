import callAjaxFunction from '../common/callAjaxFunction'
import commanComment from "../common/commanComment";
const index = () => {

    $('.cancellation-form-modal').on('change', 'select[name*=rejection_reason]', function (e) {
        if ($(e.target).val() == "Others") {
            $('#other-rejection-reason').removeClass('disabled');
            $('#other-rejection-reason').attr("disabled", false);
            $('#other-rejection-reason').attr("required", true);
        } else {
            $('#other-rejection-reason').attr("disabled", true);
            $('#other-rejection-reason').find('textarea').val('').attr("required", false);
        }
    });

    $('.datatable').on('click', '.cancel-po_request', function (e) {
        if (confirm('Do you want to '+ $(this).attr('data-id').toLowerCase() +' the PO Request?')) {
            var id = $(this).data('po-request-id')
            // var $this = $(this)
            var title = $(this).attr('data-id')

            var json = {
                url: "/overseers/po_requests/" + id + "/render_modal_form?title=" + title,
                modalId: '#cancelporequest',
                className: '.open-modal-form',
                buttonClassName: '.confirm-cancel',
                this: $(this),
                title: title
            }
            callAjaxFunction(json)
        }

    });

    commanComment('po-request','po_requests');

    $('.manualPo').unbind('click').bind('click',function () {
        $('#manualPo').modal('show')
        $('#po_request_inquiry_id').empty()
        $('.confirm-create').addClass('disabled')

    })

    $('#po_request_inquiry_id').on('change', function () {
        if($('#po_request_inquiry_id').val())
            $('.confirm-create').removeClass('disabled')
    })

    $('.confirm-create').unbind('click').bind('click',function (e) {
        let inquiry_id = $('#po_request_inquiry_id').val();
        window.open(Routes.new_overseers_inquiry_po_request_path(inquiry_id));

    })
};

export default index