import select2s from "../../components/select2s";
import deleteRow from "./deleteRowbutton";

const nextStepAction = () => {
  $('#other_reason').hide();

  $('form').on('change', 'select[id*=dc_reasons]', function (e) {
    if ($(this).select2('data')[0].text == "Other") {
      $('#other_reason').show();
    } else {
      $('#other_reason').find('textarea').val("")
      $('#other_reason').hide();
    }
  })

    deleteRow();
};

export default nextStepAction