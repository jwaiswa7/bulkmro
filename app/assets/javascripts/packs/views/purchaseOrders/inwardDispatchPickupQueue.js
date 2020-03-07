import commanComment from "../common/commanComment";
import callAjaxFunction from "../common/callAjaxFunction";

const updateLogisticsOwner = () => {
    $('.update_logistics_owner_wrapper').hide();
    toggleCheckboxes();
    $('#update_logistics_owner').click((event) => {
        updateOwner();
    });

    $('.datatable').on('click', '.comment-inward-dispatch', function (e) {
        var id = $(this).data('inward-dispatch-id')
        var purchase_id = $(this).data('purchase-id')
        var title = $(this).attr('data-title')
        var json = {
            url: "/overseers/purchase_orders/" + purchase_id + "/inward_dispatches/" + id + "/render_modal_form?title=" + title,
            modalId: '#addComment',
            className: '.open-modal-form',
            buttonClassName: '.confirm-cancel',
            this: $(this),
            title: title
        }
        callAjaxFunction(json)
    })
};


let toggleCheckboxes = () => {
    $('#all_inward_dispatches').prop("checked", false);

    $('#all_inward_dispatches').change((event) => {
        var $element = $(event.target)
        if ($element.is(':checked')) {
            $('input[type=checkbox][name="the_inward_dispatches[]"]').each((index, element) => {
                //$(element).attr('checked', 'checked')
                $(element).prop("checked", true);
                showOrHideActions();
            });
        } else {
            $('input[type=checkbox][name="the_inward_dispatches[]"]').each((index, element) => {
                //$(element).removeAttr('checked')
                $(element).prop("checked", false);
                showOrHideActions();
            });
        }
    });

    $('table').on('change', 'input[type=checkbox][name="the_inward_dispatches[]"]', (event) => {
        showOrHideActions();
    })
}

let updateOwner = () => {
    let inward_dispatches = [];
    $('input[type=checkbox][name="the_inward_dispatches[]"]:checked').each((index, element) => {
        inward_dispatches.push($(element).val());
    });

    let logistics_owner_id = $('select[name*=logistics_owner]').val();
    if (logistics_owner_id == '') {
        $.notify({
            message: 'Please Choose an Logistics Owner to Assign'
        }, {
            type: 'danger'
        });
    }

    if (inward_dispatches.length == 0) {
        $.notify({
            message: 'Please Select any Material Pickup Request you want to update'
        }, {
            type: 'danger'
        });
    }

    if (inward_dispatches.length > 0 && logistics_owner_id != '') {

        var data = JSON.stringify({inward_dispatches: inward_dispatches, logistics_owner_id: logistics_owner_id});
        $.ajax({
            url: Routes.update_logistics_owner_for_inward_dispatches_overseers_purchase_orders_path(),
            type: "POST",
            data: data,
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function () {
                var dataTable = $('.datatable').dataTable();
                dataTable.api().ajax.reload(null, false);
                $('#all_inward_dispatches').removeAttr('checked');
                $('#all_inward_dispatches').prop("checked", false);
                $.notify({
                    message: 'Logistics Owner has been successfully updated'
                }, {
                    type: 'success'
                });
            }
        });
    }


};


let showOrHideActions = () => {
    let hide = true;

    if ($('input[type=checkbox][name="the_inward_dispatches[]"]:checked').length > 0) {
        $('.update_logistics_owner_wrapper').show();
    } else {
        $('.update_logistics_owner_wrapper').hide();
    }

}

export default updateLogisticsOwner