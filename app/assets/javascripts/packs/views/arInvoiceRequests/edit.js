
const edit = () => {
    $('.delete_row').on('click', function (event) {
        $(event.target).closest('.simple-row').find('input[type="text"]').remove();
    })
}

export default edit