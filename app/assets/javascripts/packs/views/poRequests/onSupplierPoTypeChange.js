import select2s from "../../components/select2s";

const onSupplierPoTypeChange = () => {
    $("[id^='drop-ship-address']").show();
    $("[id^='warehouse-addresses']").find('select').attr('required', false);
    $("[id^='warehouse-addresses']").find('select').attr('disabled', true);

    $('form').on('change', 'select[name*=supplier_po_type]', function (e) {
        let supplierPoType = $(this).val();
        let inquiryID = $('.supplier-po-type').data('inquiry-id');
        let shipToElem = $('form').find('select[name*=ship_to_id]');
        shipToElem.empty();
        
        if (supplierPoType != '' && ['Drop Ship', 'Route Through'].includes(supplierPoType)) {
            $.get({
                url: Routes.dropbox_ship_to_overseers_inquiry_po_requests_path(inquiryID),
                data: {
                    drop_ship: true,
                    inquiry_id: inquiryID
                },
                success: function (response) {
                    shipToElem.attr('data-source', Routes.autocomplete_overseers_company_addresses_path(response.company_id)).select2('destroy');
                    select2s();
                    var option = new Option(response.address, response.address_id, true, true);
                    shipToElem.append(option).trigger('change');
                }
            });
        }else {
            shipToElem.attr('data-source', Routes.autocomplete_overseers_warehouses_path()).select2('destroy');
            select2s();
        }
    }); 
};
export default onSupplierPoTypeChange