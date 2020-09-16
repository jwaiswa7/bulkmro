// Imports
// import newAction from "./new";

const edit = () => {
    $(document).ready(function () {
        let tree = $('#tree').tree({
            primaryKey: 'id',
            uiLibrary: 'bootstrap4',
            dataSource: Routes.get_acl_overseers_acl_role_path($('#tree').attr('data-acl'), {format: "json"}),
            checkboxes: true
        });

        let menu_tree = $('#menu_tree').tree({
            primaryKey: 'id',
            uiLibrary: 'bootstrap4',
            dataSource: Routes.get_acl_menu_overseers_acl_role_path($('#menu_tree').attr('data-acl'), {format: "json"}),
            checkboxes: true
        });

        tree.collapseAll();

        $('#btnSave').on('click', function () {
            console.log("button clicked")
            let checked_ids = tree.getCheckedNodes();
            let menu_checked_ids = menu_tree.getCheckedNodes();

            let result = [],
                checkboxes = tree.find('li [data-role="checkbox"] input[type="checkbox"]');
            $.each(checkboxes, function () {
                let checkbox = $(this);
                if (checkbox.checkbox('state') === 'unchecked') {
                    result.push(checkbox.closest('li').data('id'));
                }
            });
            let unchecked_ids = result;

            $.ajax({
                url: Routes.overseers_acl_role_path(
                    $('#tree').attr('data-acl')
                ),
                dataType: 'json',
                data: {checked_ids: checked_ids, unchecked_ids: unchecked_ids, menu_checked_ids: menu_checked_ids, is_default: $('#acl_role_is_default').is(':checked')},
                method: 'PATCH'
            })
                .done(function( data ) {
                    window.location.href = Routes.edit_overseers_acl_role_path($('#tree').attr('data-acl'))
                })
                .fail(function () {
                    alert('Failed to save.');
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

export default edit