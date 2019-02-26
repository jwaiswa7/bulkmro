import select2s from "../../components/select2s";

const newAction = () => {
    $('form').on('change', 'select[id*=document_creation_inquiry]', function (e) {
        let reset = true;
        onInquiryChange(this, reset);
    }).find('select[id*=document_creation_inquiry]').each(function (e) {
        let reset = false;
        onInquiryChange(this, reset);
    });

    // $('form').on('change', '#document_creation_option', function (e) {
    //    debugger
    // });
};

let onInquiryChange = (container, reset) => {
    let optionSelected = $("option:selected", container);

    if (optionSelected.exists() && optionSelected.val() !== '') {
        if (reset) {
            $("#document_creation_sales_order").val(null).trigger("change");
        }
        $('#document_creation_sales_order').attr('data-source', Routes.autocomplete_overseers_inquiry_sales_orders_path(optionSelected.val())).select2('destroy');
        select2s();
    }
};

export default newAction