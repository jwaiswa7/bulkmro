
const kraReport = () => {
    var dataTable = $('.datatable').dataTable();
    dataTable.api().page.len(-1).draw()
    dataTable.on('draw.dt', function () {
        console.log($('.dataTables_paginate'))
        $('.dataTables_paginate').hide()
    })
}

export default kraReport