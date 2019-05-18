import newAction from "./new";

const edit = () => {
    newAction();

    $('form').on('change', 'select[name*=product_id]', function (e) {
        onProductChange(this);
    }).find('select[name*=product_id]').each(function (e) {
        onProductChange(this);
    });

    $('.duplicate-inquiry').on('click', function(){
        gtag('event','click-duplicate', { event_category: 'duplicate-inquiry',  event_label: 'Duplicate Inquiry'})
    })
};

let onProductChange = (container) => {
    let optionSelected = $("option:selected", container);
    let select = $(container).closest('select');

    if (optionSelected.exists() && optionSelected.val() !== '') {
        $.getJSON({
            url: Routes.customer_bp_catalog_overseers_product_path(optionSelected.val()),
            data: {
                company_id: $('#inquiry_company_id').val()
            },

            success: function (response) {
                select.closest('div.form-row').find('[name*=bp_catalog_name]').val(response.bp_catalog_name);
                select.closest('div.form-row').find('[name*=bp_catalog_sku]').val(response.bp_catalog_sku);
            }
        });
    }
};

export default edit