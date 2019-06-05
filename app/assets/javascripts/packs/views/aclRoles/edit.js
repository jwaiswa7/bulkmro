// Imports
// import newAction from "./new";

const edit = () => {
    $(document).ready(function () {
        var tree = $('#tree').tree({
            primaryKey: 'id',
            uiLibrary: 'bootstrap4',
            dataSource: Routes.get_acl_overseers_acl_role_path($('#tree').attr('data-acl'), {format: "json"}),
            checkboxes: true
        });

        tree.collapseAll();

        $('#btnSave').on('click', function () {
            console.log("button clicked")
            var checkedIds = tree.getCheckedNodes();
            $.ajax({
                url: Routes.overseers_acl_role_path(
                    $('#tree').attr('data-acl')
                ),
                dataType: 'json',
                data: {checkedIds: checkedIds},
                method: 'PATCH'
            })
                .done(function( data ) {
                    window.location.href = Routes.edit_overseers_acl_role_path($('#tree').attr('data-acl'))
                })
                .fail(function () {
                    alert('Failed to save.');
                });
        });

        $('#checkAll').on('click', function () {
            tree.checkAll();
        });

        $('#uncheckAll').on('click', function () {
            tree.uncheckAll();
        });

        $('#expand').on('click', function () {
            tree.expandAll();
        });

        $('#collapse').on('click', function () {
            tree.collapseAll();
        });

    });
};

export default edit