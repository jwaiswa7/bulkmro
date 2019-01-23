import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
const newAction = () => {

    bindRatingModalTabClick();
    $('.rating-modal a').click();

    var customTabSelector =  $('#multipleRatingForm .custom-tab')
    customTabSelector.eq(0).removeClass('disabled')
    customTabSelector[0].click();
    let tabsLength =customTabSelector.length
    $("#multipleRatingForm").on('click','.submit-rating',function(event){
        var formSelector = "#"+$(this).closest('form').attr('id')
        let datastring = $(formSelector).find("input").serialize()
        $.ajax({
            type: "POST",
            url: $(formSelector).attr('action'),
            data: datastring,
            dataType: "json",
            success: function(data) {
                var activeTab = $('#multipleRatingForm .custom-tab.active').data('index')
                if(activeTab < (tabsLength - 1)){
                   customTabSelector.eq(activeTab+1).removeClass('disabled')
                   customTabSelector.eq(activeTab+1).click();
                }
                else
                    $('#multipleRatingForm').modal('hide')
            },
            error: function(error) {
                $(formSelector).find('.error').empty().text(error.responseJSON.error)
            }
        });
        event.preventDefault();

    });
};

export default newAction