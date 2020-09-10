import select2s from "../../components/select2s";

const newAction = () => {
  $('form').on('change', 'select[id*=dc_inquiry_select]', function (e) {
    let reset = true;
    onInquiryChange(this, reset);
  }).find('select[id*=dc_inquiry_select]').each(function (e) {
    let reset = false;
    onInquiryChange(this, reset);
  });

  $('form').on('change', 'select[id*=dc_purpose]', function (e) {
    if ($(this).select2('data')[0].text == "Sample") {
      $("#dc_sales_order_select").prop("disabled", true);
      $("#dc_sales_order_select").prop("required", false);
    } else {
      $("#dc_sales_order_select").prop("disabled", false);
      $("#dc_sales_order_select").prop("required", true);
    }
  })
};

let onInquiryChange = (container, reset) => {
  let optionSelected = $("option:selected", container);

  if (optionSelected.exists() && optionSelected.val() !== '') {
    if (reset) {
      $("#dc_sales_order_select").val(null).trigger("change");
    }
    $('#dc_sales_order_select').attr('data-source', Routes.autocomplete_overseers_inquiry_sales_orders_path(optionSelected.val())).select2('destroy');
    select2s();
  }
};


export default newAction