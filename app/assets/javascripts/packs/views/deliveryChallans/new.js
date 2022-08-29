import select2s from "../../components/select2s";

const newAction = () => {
  $("#dc_sales_order_select").prop("required", true);
  $('form').on('change', 'select[id*=dc_inquiry_select]', function (e) {
    let reset = true;
    onInquiryChange(this, reset);
  }).find('select[id*=dc_inquiry_select]').each(function (e) {
    let reset = false;
    onInquiryChange(this, reset);
  });

  $('#dc_purpose').on('select2:select', function (e) {
    if ($(this).select2('data')[0].text == "Sample") {
      $("#delivery_challan_can_create_delivery_challan_yes").prop("checked", true);
      $("#delivery_challan_can_create_delivery_challan_no").prop("disabled", true);
      $("#dc_sales_order_select").attr("required", false);
      $("#dc_sales_order_select").parent().children().removeClass('is-invalid');
      $("#dc_sales_order_select").parent().find('span .select2-selection').removeClass('is-invalid');
    } else {
     $("#delivery_challan_can_create_delivery_challan_no").prop("disabled", false);
      $("#dc_sales_order_select").prop("required", true);
    }
  });

  $("#dc_sales_order_select").on('select2:select', function (e) {
    $(this).parent().children().removeClass('is-invalid');
    $(this).parent().find('span .select2-selection').removeClass('is-invalid');
  });

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