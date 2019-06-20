// Imports
import newAction from "./new";

const editAcl = () => {
    $(document).ready(function () {

        var tree = $('#tree').tree({
            primaryKey: 'id',
            uiLibrary: 'bootstrap4',
            dataSource: Routes.get_resources_overseers_overseer_path($('#tree').attr('data-overseer'), {format: "json"}),
            checkboxes: true,
            lazyLoading: true
        });

        var menu_tree = $('#menu_tree').tree({
            primaryKey: 'id',
            uiLibrary: 'bootstrap4',
            dataSource: Routes.get_menu_resources_overseers_overseer_path($('#tree').attr('data-overseer'), {format: "json"}),
            checkboxes: true,
            lazyLoading: true
        });


        // tree.collapseAll();

        $('#btnSave').on('click', function () {
            var checked_ids = tree.getCheckedNodes();
            var menu_checked_ids = menu_tree.getCheckedNodes();
            $.ajax({
                url: Routes.update_acl_overseers_overseer_path(
                    $('#tree').attr('data-overseer'),
                    {format: "json"}
                ),
                dataType: 'json',
                data: {
                    checked_ids: checked_ids,
                    menu_checked_ids: menu_checked_ids,
                    acl_role_id: $('#overseer_acl_role_id').val()
                },
                method: 'PATCH'
            })
                .done(function (data) {
                    window.location.href = Routes.edit_acl_overseers_overseer_path($('#tree').attr('data-overseer'))
                })
                .fail(function () {
                    alert('Failed to save.');
                });
        });

        $('#overseer_acl_role_id').on('change', function () {
            let role_id = $('#overseer_acl_role_id').val()
            $.ajax(Routes.get_role_resources_overseers_acl_role_path(role_id, {format: "json"}),   // request url
                {
                    beforeSend: function () {
                        $('.fa-spinner-third').show()
                        $('#tree').hide()
                    },
                    success: function (data, status, xhr) {// success callback function
                        tree.uncheckAll();
                        $.each(data, function (index, value) {
                            if (typeof tree.getNodeById(value) !== "undefined") {
                                tree.check(tree.getNodeById(value))
                            }
                        });
                        $('.fa-spinner-third').hide()
                        $('#tree').show()
                    },
                    complete: function () {
                        $('.fa-spinner-third').hide()
                        $('#tree').show()
                    },
                    error: function (xhr) { // if error occured
                        alert("Error occured.please try again");
                    }
                });
        });

        $('#checkAllMenu').on('click', function () {
            menu_tree.checkAll();
        });

        $('#uncheckAllMenu').on('click', function () {
            menu_tree.uncheckAll();
        });

        $('#expandMenu').on('click', function () {
            menu_tree.expandAll();
        });

        $('#collapseMenu').on('click', function () {
            menu_tree.collapseAll();
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
        $('.fa-spinner-third').hide()
    });
};

export default editAcl