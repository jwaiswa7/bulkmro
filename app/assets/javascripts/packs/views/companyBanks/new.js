import easyAutocomplete from "../../components/easyAutocomplete";

const newAction = () => {
    $('#company_bank_account_number_confirmation').on('change',function(e){
            if($("input[name*=account_number]").val() != $("input[name*=account_number_confirmation]").val()){
                setTimeout(function(){
                $("#company_bank_account_number_confirmation").removeClass('is-valid').addClass('is-invalid')
                $('.company_bank_account_number_confirmation').find('.valid-feedback').remove()
                $('.company_bank_account_number_confirmation').append("<div class='invalid-feedback'>Account number confirmation doesn\'t match Account number</div>")
                }, 50);
            }else{
                setTimeout(function(){
                    $('.company_bank_account_number_confirmation').find('.invalid-feedback').remove()
                    // $('.company_bank_account_number_confirmation').append("<div class='valid-feedback'>Looks good!</div>")
                    $("#company_bank_account_number_confirmation").removeClass('is-invalid').addClass('is-valid')
                }, 50);

            }

    })

    easyAutocomplete('#company_bank_ifsc_code_number', createOptions('#company_bank_ifsc_code_number'))
};

const createOptions = (classname) => {
    let url = Routes.suggestion_overseers_ifsc_codes_path
    let options = {
        url: function(phrase) {
            if (phrase !== "") {
                return url({prefix: phrase});
            } else {
                return url;
            }
        },

        listLocation: 'ifsc_codes',

        getValue: 'ifsc_complete',

        list: {
            onSelectItemEvent: function() {
                let selectedBranch = $(classname).getSelectedItemData()['branch'];
                let selectedAddress= $(classname).getSelectedItemData()['address'];
                let selectedAddress2= $(classname).getSelectedItemData()['merged_address'];
                let selectedBank= $(classname).getSelectedItemData()['bank_id'];
                let selectedIFSC= $(classname).getSelectedItemData()['id'];

                $("#company_bank_branch").val(selectedBranch).trigger('change');
                $("#company_bank_address_line_1").val(selectedAddress).trigger('change');
                $("#company_bank_address_line_2").val(selectedAddress2).trigger('change');
                $("select[name='company_bank[bank_id]']").val(selectedBank).trigger('change');
                $("#company_bank_ifsc_code_id").val(selectedIFSC).trigger('change');
            },
            onHideListEvent: function() {
                var selectedItemValue = $(classname).val();
                if (selectedItemValue.length < 11)
                    $("#company_bank_branch").val("").trigger('change');
            }
        }

    };
    return options
}

export default newAction