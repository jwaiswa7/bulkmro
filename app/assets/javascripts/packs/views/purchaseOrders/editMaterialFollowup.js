import disableBackdateOption from "../common/disableBackdateOption";

const editMaterialFollowup = () => {
    $('.supplier-dispatch-date').on("focus", function () {
        disableBackdateOption( $('.supplier-dispatch-date'));
    });

    $('.revised-supplier-delivery-date').on("focus", function () {
        disableBackdateOption( $('.revised-supplier-delivery-date'));
    });

    $('.followup-date').on("focus", function () {
        disableBackdateOption( $('.followup-date'));
    });

    if ($('#po_message').select2('data')[0].text == "Others") {
        $("#po_other_message").prop("required", true);
        $("#po_other_message").prop("disabled", false);
    }
    else{
        $("#po_other_message").val('');
    }

    $('#po_message').on('select2:select', function (e) {
        if ($(this).select2('data')[0].text != "Others") {
          $("#po_other_message").val('');
          $("#po_other_message").prop("disabled", true);
          $("#po_other_message").attr("required", false);
          $("#po_other_message").parent().children().removeClass('is-invalid');
          $("#po_other_message").parent().find('span .select2-selection').removeClass('is-invalid');
        } else {
          $("#po_other_message").prop("required", true);
          $("#po_other_message").prop("disabled", false);
        }
      });
}

export default editMaterialFollowup