import select2s from "../../components/select2s";

const newAction = () => {
  $(document).on("fields_added.nested_form_fields", function (event, param) {
    $('.serial_number:last').val($('.serial_number:visible').length);

  });
  $(document).on("fields_removed.nested_form_fields", function (event, param) {
    for (var i = 0; i < $('.serial_number:visible').length; i++) {
      $($('.serial_number:visible')[i]).val(i + 1)
    }

  });
  $('form').on('change', 'select[name*=product_id]', function (e) {
    onProductChange(this);
  }).find('select[name*=product_id]').each(function (e) {
    onProductChange(this);
  });

  $('form').on('change', 'select[name*=shipping_company_id]', function (e) {
    let reset = true;
    onShippingCompanyChange(this, reset);
  }).find('select[name*=shipping_company_id]').each(function (e) {
    let reset = false;
    onShippingCompanyChange(this, reset);
  });

  $('form').on('change', 'select[name*=billing_company_id]', function (e) {
    let reset = true;
    onBillingCompanyChange(this, reset);
  }).find('select[name*=billing_company_id]').each(function (e) {
    let reset = false;
    onBillingCompanyChange(this, reset);
  });

};

let onShippingCompanyChange = (container, reset) => {
  let optionSelected = $("option:selected", container);

  if (optionSelected.exists() && optionSelected.val() !== '') {

    if (reset) {
      $("#customer_rfq_shipping_address_id").val(null);
    }

    $('#customer_rfq_shipping_address_id').removeAttr('disabled', false);
    $('#customer_rfq_shipping_address_id').attr('data-source', Routes.autocomplete_customers_company_addresses_path(optionSelected.val())).select2('destroy');
    select2s();
  }
};

let onBillingCompanyChange = (container, reset) => {
  let optionSelected = $("option:selected", container);

  if (optionSelected.exists() && optionSelected.val() !== '') {

    if (reset) {
      $("#customer_rfq_billing_address_id").val(null);
    }

    $('#customer_rfq_billing_address_id').removeAttr('disabled', false);
    $('#customer_rfq_billing_address_id').attr('data-source', Routes.autocomplete_customers_company_addresses_path(optionSelected.val())).select2('destroy');

    select2s();
  }
};

let onProductChange = (container) => {
  let optionSelected = $("option:selected", container);
  let select = $(container).closest('select');

  if (optionSelected.exists() && optionSelected.val() !== '') {
    $.getJSON({
      url: Routes.get_product_details_overseers_product_path(optionSelected.val()),
      success: function (response) {
        select.closest('div.form-row').find('[name*=bp_catalog_name]').val(response.mpn);
        select.closest('div.form-row').find('[name*=bp_catalog_sku]').val(response.category);
        select.closest('div.form-row').find('#brand').val(response.brand);
      }
    });
  }
};
export default newAction