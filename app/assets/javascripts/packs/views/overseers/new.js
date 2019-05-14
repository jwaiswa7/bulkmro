const newAction = () => {
    $(document).ready(function () {
        var tree = $('#tree').tree({
            primaryKey: 'id',
            uiLibrary: 'bootstrap4',
            dataSource: Routes.get_resources_overseers_overseer_path($('#tree').attr('data-overseer'), {format: "json"}),
            checkboxes: true
        });

        tree.collapseAll();

        $('#btnSave').on('click', function () {
            console.log("button clicked")
            var checkedIds = tree.getCheckedNodes();
            $.ajax({
                url: Routes.update_acl_overseers_overseer_path(
                    $('#tree').attr('data-overseer'),
                    {format: "json"}
                ),
                dataType: 'json',
                data: {checkedIds: checkedIds, acl_role_id: $('#overseer_acl_role_id').val()},
                method: 'PATCH'
            })
            .done(function( data ) {
                window.location.href = Routes.edit_acl_overseers_overseer_path($('#tree').attr('data-overseer'))
            })
            .fail(function () {
                alert('Failed to save.');
            });
        });

        $('#overseer_acl_role_id').on('change', function () {
            let pp = $('#overseer_acl_role_id').val()
            let tree2 = $('#tree').tree({
                primaryKey: 'id',
                uiLibrary: 'bootstrap4',
                dataSource: Routes.get_acl_overseers_acl_role_path(pp, {format: "json"}),
                checkboxes: true
            });
        });

    });


};

export default newAction