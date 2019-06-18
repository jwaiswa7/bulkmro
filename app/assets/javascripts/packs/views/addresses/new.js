const newAction = () => {
    $("#address_address_state_id").on('change',function(){
        var state_id = $(this).val();
        $.ajax({
            url: Routes.get_gst_code_overseers_addresses_path(),
            data: { state_id: state_id },
            contentType: "application/json; charset=utf-8",
            dataType: "json",

            success: function (data) {
                $('#gst_code_1').val(data.gst_code)
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

            $('#gst_code_1').val(gst_cd1)
            $('#gst_code_2').val(gst_cd2)
            $('#gst_code_3').val(gst_cd3)
            $('#gst_code_4').val(gst_cd4)
            $('#gst_code_5').val(gst_cd5)
        }
    })


    $('.gst-change').on('input', function() {
        $('#address_gst').val($('#gst_code_1').val()+$('#gst_code_2').val()+$('#gst_code_3').val()+$('#gst_code_4').val()+$('#gst_code_5').val());
    });
}

export default newAction