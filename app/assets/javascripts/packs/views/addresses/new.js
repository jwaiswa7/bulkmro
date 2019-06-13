const newAction = () => {
    $("#address_address_state_id").on('change',function(){
        var state_id = $(this).val();
        $.ajax({
            url: Routes.get_gst_code_overseers_addresses_path(),
            data: { state_id: state_id },
            contentType: "application/json; charset=utf-8",
            dataType: "json",

            success: function (data) {
                $('#cd1').val(data.gst_code)
                $('#address_gst').val('');
            }
        });

    })

    $(document).ready(function() {
        if ($('#address_gst').val() != ''){
            var full_gst_code = $('#address_gst').val()
            var gst_cd1 = full_gst_code.substring(0, 2);
            var gst_cd2 = full_gst_code.substring(2, 12);
            var gst_cd3 = full_gst_code.substring(12, 13);
            var gst_cd4 = full_gst_code.substring(13, 14);
            var gst_cd5 = full_gst_code.substring(14, 15);

            $('#cd1').val(gst_cd1)
            $('#cd2').val(gst_cd2)
            $('#cd3').val(gst_cd3)
            $('#cd4').val(gst_cd4)
            $('#cd5').val(gst_cd5)
        }
    })


    $('.gst-change').on('input', function() {
        $('#address_gst').val($('#cd1').val()+$('#cd2').val()+$('#cd3').val()+$('#cd4').val()+$('#cd5').val());
    });
}

export default newAction