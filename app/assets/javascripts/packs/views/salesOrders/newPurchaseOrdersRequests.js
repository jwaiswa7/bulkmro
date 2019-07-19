import updateRowTotal from "../poRequests/updateRowTotal"
import validatePoRequestAddresses from "../poRequests/validatePoRequestAddresses"
import validatePoRequestContacts from "../poRequests/validatePoRequestContacts"
import updateOnContactSelect from "../poRequests/updateOnContactSelect";
import validateLeadDate from "../poRequests/validateLeadDate";
import massLeadDateUpdate from "../poRequests/massLeadDateUpdate";

const newPurchaseOrdersRequests = () => {
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
    validatePoRequestAddresses();
    validatePoRequestContacts();
    updateRowTotal();

    updateOnContactSelect();
    validateLeadDate();
    massLeadDateUpdate();
};

export default newPurchaseOrdersRequests