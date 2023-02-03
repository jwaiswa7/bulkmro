import updateRowTotal from "../poRequests/updateRowTotal"
import validatePoRequestAddresses from "../poRequests/validatePoRequestAddresses"
import validatePoRequestContacts from "../poRequests/validatePoRequestContacts"
import updateOnContactSelect from "../poRequests/updateOnContactSelect";
import validateLeadDate from "../poRequests/validateLeadDate";
import massLeadDateUpdate from "../poRequests/massLeadDateUpdate";
import onScrollandClickSideMenu from '../common/ScrollandClickSideMenu';
import select2s from "../../components/select2s";


const newPurchaseOrdersRequests = () => {

    $('form').on('change', 'select[name*=supplier_id]', function (e) {
        let reset = true;
        onSupplierChange(this, reset);
    }).find('select[name*=supplier_id]').each(function (e) {
        let reset = false;
        onSupplierChange(this, reset);
    });


    $('form').on('change', 'select[name*=contact_id]', function (e) {
        let reset = true;
        onContactChange(this, reset);
    }).find('select[name*=contact_id]').each(function (e) {
        let reset = false;
        onContactChange(this, reset);
    })

    $('#warehouse-div').attr('data-warehouse-id',$('#sales_order_po_requests_attributes_0_bill_to_id option:selected').data('warehouse-state'));

    $('#sales_order_po_requests_attributes_0_bill_to_id').on('change',function(){
        $('#warehouse-div').attr('data-warehouse-id',$('#sales_order_po_requests_attributes_0_bill_to_id option:selected').data('warehouse-state'));
    })

    $('.product-stock-inventory').on('click',function(){
        var productId = $(this).data('product-id')
        var url = '/overseers/po_requests/product_resync_inventory?product_id='+productId
        $.ajax({
            url: url,
            data: {},
            success: function(data){
                $('#product_inventory_div').empty()
                $('#product_inventory_div').append(data)
                $('#product_inventory').modal('show')
            }
        })
    })
    // validatePoRequestAddresses();
    validatePoRequestContacts();
    updateRowTotal();

    updateOnContactSelect();
    validateLeadDate();
    massLeadDateUpdate();
    onScrollandClickSideMenu();
};

let onSupplierChange = (container, reset) => {
    let optionSelected = $("option:selected", container);
    let select = $(container).closest('select');
    let containerId = $(container).closest('select').attr('id');
    let containerIdString = containerId.substring(0, containerId.length - 11);

    if (optionSelected.exists() && optionSelected.val() !== '') {
        if (reset) {
            $(`#${containerIdString}bill_from_id`).val(null);
            $(`#${containerIdString}ship_from_id`).val(null);
            $(`#${containerIdString}contact_id`).val(null);

        }
        $('form').find('input[name*=contact_phone]').val('');
        $('form').find('input[name*=contact_email]').val('');
        $(`#${containerIdString}bill_from_id`).attr('data-source', Routes.autocomplete_overseers_company_addresses_path(optionSelected.val())).select2('destroy');
        $(`#${containerIdString}ship_from_id`).attr('data-source', Routes.autocomplete_overseers_company_addresses_path(optionSelected.val())).select2('destroy');
        $(`#${containerIdString}contact_id`).attr('data-source', Routes.autocomplete_overseers_company_contacts_path(optionSelected.val())).select2('destroy');


        select2s();
    }

};

let onContactChange = (container) => {
    let optionSelected = $("option:selected", container);
    let select = $(container).closest('select');

    if (optionSelected.exists() && optionSelected.val() !== '') {
        $.ajax({
            url: Routes.get_contacts_overseers_companies_path(),
            data: {attribute_id: optionSelected.val() },
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function success(data) {
                if(data.contact_email){
                    $('form').find('input[name*=contact_email]').val(data.contact_email);
                }else{
                    $('form').find('input[name*=contact_email]').val('');
                }
                if(data.contact_mobile){
                    $('form').find('input[name*=contact_phone]').val(data.contact_mobile);
                }else{
                    $('form').find('input[name*=contact_phone]').val('');
                }
            },
        })
    }
};
export default newPurchaseOrdersRequests

