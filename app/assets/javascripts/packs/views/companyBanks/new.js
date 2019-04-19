import easyAutocomplete from "../../components/easyAutocomplete";

const newAction = () => {
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

        getValue: 'text',

        list: {
            onSelectItemEvent: function() {
                let selectedBranch = $(classname).getSelectedItemData()._source["branch"];
                let selectedAddress= $(classname).getSelectedItemData()._source["address"];
                let selectedAddress2= $(classname).getSelectedItemData()._source["merged_address"];
                let selectedBank= $(classname).getSelectedItemData()._source["bank_id"];
                let selectedIFSC= $(classname).getSelectedItemData()._source["id"];

                $("#company_bank_branch").val(selectedBranch).trigger("change");
                $("#company_bank_address_line_1").val(selectedAddress).trigger("change");
                $("#company_bank_address_line_2").val(selectedAddress2).trigger("change");
                $("select[name='company_bank[bank_id]']").val(selectedBank).trigger("change");
                $("#company_bank_ifsc_code_id").val(selectedIFSC).trigger("change");
            },
            onHideListEvent: function() {
                var selectedItemValue = $(classname).val();
                if (selectedItemValue.length < 11)
                    $("#company_bank_branch").val("").trigger("change");
            }
        }

    };
    return options
}

export default newAction