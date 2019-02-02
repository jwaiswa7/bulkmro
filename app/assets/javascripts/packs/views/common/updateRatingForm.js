const updateRatingForm = () => {
    var customTabSelector =  $('#multipleRatingForm .custom-tab')
    if (customTabSelector.length > 0) {
        customTabSelector.eq(0).removeClass('disabled')
        customTabSelector[0].click();
    }
    var tabsLength =customTabSelector.length
    $("#multipleRatingForm").on('click','.submit-rating',function(event){
        var formSelector = "#"+$(this).closest('form').attr('id')
        var datastring = $(formSelector).find("input").serialize()
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
                    $(formSelector).find('.error').empty()
                }
                else
                    $('#multipleRatingForm').modal('hide')
            },
            error: function(error) {
                if (error.responseJSON.error)
                    $(formSelector).find('.error').empty().html("<div class='p-1'>"+ error.responseJSON.error+ "</div>")
            }
        });
        event.preventDefault();

    });
}
export default updateRatingForm

