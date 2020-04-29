



const myteamDropdown=function(){
$('.bmro-drop-icon-head-fl').click((e)=>{
        let current =e.currentTarget.parentElement.parentElement;
        console.log(current)
        if(e.currentTarget.classList.contains('bmro-drop-icon-head-rotated-up'))
        {
            e.currentTarget.classList.remove('bmro-drop-icon-head-rotated-up');
            e.currentTarget.classList.add('bmro-drop-icon-head');
            current.nextElementSibling.remove()
        }
        else {
            let url = '/overseers/dashboard/get_recent_inquiries'
            $.ajax({
                type: "GET",
                url: url,
                data: {overseer_id: e.currentTarget.id},
                success: function (result) {
                    e.currentTarget.classList.add('bmro-drop-icon-head-rotated-up');
                    e.currentTarget.classList.remove('bmro-drop-icon-head');
                    let addElement = $(result);
                    addElement.insertAfter(current);
                }
            })
        }
    });
}

    export default myteamDropdown;