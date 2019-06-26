const newAction = () => {
    $(document).ready(function () {
        var tree = $('#tree').tree({
            primaryKey: 'id',
            uiLibrary: 'bootstrap4',
            dataSource: Routes.get_default_resources_overseers_acl_roles_path({format: "json"}),
            checkboxes: true
        });

        $('#btnSave').on('click', function () {
            console.log("button clicked")
            var checkedIds = tree.getCheckedNodes();
            $.ajax({
                url: Routes.save_role_overseers_acl_role_path({format: "json"}),
                dataType: 'json',
                data: {checkedIds: checkedIds, role_name:$('#acl_role_role_name').val()},
                method: 'POST'
            })
            .done(function( data ) {
                window.location.href = Routes.overseers_acl_roles_path
            })
            .fail(function () {
                alert('Failed to save.');
            });
        });
    });

};

export default newAction