import select2s from "../../components/select2s";
import onScrollandClickSideMenu from '../common/ScrollandClickSideMenu';
import disableBackdateOption from "../common/disableBackdateOption";

const newAction = () => {

    var route_through_value = "\n7. Bulk MRO will not be responsible for any changes done by the vendor in terms of product specifications.\n8. Any costs incurred by Bulk MRO for warranty claim will be reimbursed by the customer."

    $('form').on('change', 'select[name*=shipping_company_id]', function (e) {
        let reset = true;
        onShippingCompanyChange(this, reset);
    }).find('select[name*=shipping_company_id]').each(function (e) {
        let reset = false;
        onShippingCompanyChange(this, reset);
    });

    $('form').on('change', 'select[name*=billing_address_id]', function (e) {
        onBillingAddressChange(this);
    })

    $('form').on('change', 'select[name*=company_id]', function (e) {
        let reset = true;
        onCompanyChange(this, reset);
    }).find('select[name*=company_id]').each(function (e) {
        let reset = false;
        onCompanyChange(this, reset);
    });
    onScrollandClickSideMenu();
    $('[name="inquiry[quotation_followup_date]').on("focus", function () {
        var newDate = Date.parse(new Date())
        disableBackdateOption($('[name="inquiry[quotation_followup_date]'), true, moment(newDate).format('DD-MMM-YYYY'));
    });

    if ($('#inquiry_opportunity_type').select2('data')[0].text == "Route through" && $("#inquiry_commercial_terms_and_conditions")[0].value.search(route_through_value) == -1) {
        var commercial_terms_and_conditions = $("#inquiry_commercial_terms_and_conditions")[0].value;
        commercial_terms_and_conditions = commercial_terms_and_conditions + route_through_value
        $("#inquiry_commercial_terms_and_conditions").val(commercial_terms_and_conditions);
    }
    else if ($("#inquiry_commercial_terms_and_conditions")[0].value.search(route_through_value) == -1) {
        var commercial_terms_and_conditions = $("#inquiry_commercial_terms_and_conditions")[0].value;
        commercial_terms_and_conditions = commercial_terms_and_conditions.replace(route_through_value, "");
        $("#inquiry_commercial_terms_and_conditions").val(commercial_terms_and_conditions);
    }

    $('#inquiry_opportunity_type').on('select2:select', function (e) {
        if ($(this).select2('data')[0].text == "Route through" && $("#inquiry_commercial_terms_and_conditions")[0].value.search(route_through_value) == -1) {
            var commercial_terms_and_conditions = $("#inquiry_commercial_terms_and_conditions")[0].value;
            commercial_terms_and_conditions = commercial_terms_and_conditions + route_through_value
            $("#inquiry_commercial_terms_and_conditions").val(commercial_terms_and_conditions);
        }
        else {
            var commercial_terms_and_conditions = $("#inquiry_commercial_terms_and_conditions")[0].value;
            commercial_terms_and_conditions = commercial_terms_and_conditions.replace(route_through_value, "");
            $("#inquiry_commercial_terms_and_conditions").val(commercial_terms_and_conditions);
        }
    });

};

let onShippingCompanyChange = (container, reset) => {
    let optionSelected = $("option:selected", container);

    if (optionSelected.exists() && optionSelected.val() !== '') {
        if (reset) {
            $("#inquiry_shipping_address_id, #inquiry_shipping_contact_id").val(null).trigger("change");
        }

        $('#inquiry_shipping_address_id').attr('data-source', Routes.autocomplete_overseers_company_addresses_path(optionSelected.val())).select2('destroy');
        $('#inquiry_shipping_contact_id').attr('data-source', Routes.autocomplete_overseers_company_contacts_path(optionSelected.val())).select2('destroy');

        select2s();
    }
};

let onBillingAddressChange = function onBillingAddressChange(container) {
    let optionSelected = $("option:selected", container);
    if (optionSelected.exists() && optionSelected.val() !== '') {
        $.getJSON({
            url: Routes.is_sez_params_overseers_addresses_path(),
            data: {
                address_id: optionSelected.val()
            },
            success: function success(response) {
                $('select#inquiry_is_sez option[value="' + response.is_sez + '"').prop('selected', 'selected')
            }
        });
    }
};

let onCompanyChange = (container, reset) => {
    let optionSelected = $("option:selected", container);

    if (optionSelected.exists() && optionSelected.val() !== '') {
        $.getJSON
            (
                {
                    url: Routes.get_account_overseers_company_path(optionSelected.val()),
                    success: function (response) {
                        $('#inquiry_account_id').val(response.account_id);
                        $('#inquiry_account').val(response.account_name);
                        $('#inquiry_contact_id').removeAttr('disabled', false);
                        $('#inquiry_shipping_contact_id').removeAttr('disabled', false);
                    }
                }
            );

        if (reset) {
            $("#inquiry_contact_id, #inquiry_shipping_contact_id").val(null);
        }

        $('#inquiry_contact_id').attr('data-source', Routes.autocomplete_overseers_company_contacts_path(optionSelected.val())).select2('destroy');
        $('#inquiry_shipping_contact_id').attr('data-source', Routes.autocomplete_overseers_company_contacts_path(optionSelected.val())).select2('destroy');

        select2s();

    }
};


export default newAction