const edit = () => {

    $('.add-transaction').on('click',function(){
        setTimeout(function(){
            dueDate();
        }, 1000);
    })
    dueDate();


}

const dueDate = () => {
    let months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May',
        'Jun', 'Jul', 'Aug', 'Sep',
        'Oct', 'Nov', 'Dec'
    ];
    $('input[name*=transaction_due_date]').on('change',function(){
        let diff = [];
        $('.transaction-due-date').each(function() {
            let paymentDueDate = $(this).data('due-date') ? new Date($(this).data('due-date')) : new Date();
            let due_date = $(this).val();
            diff.push(new Date(due_date).getTime())
        })
        let latest_date = diff.sort()
        console.log(latest_date)
        if (latest_date[0]){
            let new_due_date = ( new Date(latest_date[0]).getDate() + '-' + months[new Date(latest_date[0]).getMonth()] + '-' +  new Date(latest_date[0]).getFullYear())
            $('#payment_request_due_date').val(new_due_date).trigger('change')
        }
    })
}

export default edit