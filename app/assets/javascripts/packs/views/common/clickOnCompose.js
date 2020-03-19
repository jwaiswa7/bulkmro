const clickOnCompose = function () {
    $(".compose-email").click(function (e) {
        let inquiry_number = $(this).data('id');
        e.preventDefault();
        $.ajax({
            url: Routes.show_email_message_modal_overseers_dashboard_path({format: "html"}),
            type: "GET",
            data: {
                inquiry_number: inquiry_number
            },
            success: function (data) {
                $('#email_message').empty();
                $('#email_message').append(data);
                tinymce.init({
                    selector: '.html-editor',
                    plugins: "fullpage code autoresize",
                    skin: 'lightgray',
                    toolbar: 'undo redo | bold italic | link | code',
                    menubar: false,
                    fullpage_default_doctype: '<!DOCTYPE html>',
                    fullpage_default_encoding: "UTF-8",
                    visual: false
                });
            },
        });
    });

    $('#myModal').on('hidden.bs.modal', function () {
        tinymce.remove('.html-editor');
    });
}
export default clickOnCompose