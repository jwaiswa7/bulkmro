



const myteamDropdown=function(){
$('.bmro-drop-icon-head-fl').click((e)=>{
    debugger
        let current =e.currentTarget.parentElement.parentElement;
        console.log(current)
        if(e.currentTarget.classList.contains('bmro-drop-icon-head-rotated-up'))
        {
            e.currentTarget.classList.remove('bmro-drop-icon-head-rotated-up');
            e.currentTarget.classList.add('bmro-drop-icon-head');
            current.nextElementSibling.remove()
        }
        else {
            e.currentTarget.classList.add('bmro-drop-icon-head-rotated-up');
            e.currentTarget.classList.remove('bmro-drop-icon-head');
            let addElement= $(`<tr class="bmro-back-color-ackwo"><td colspan="7"><div class="dropdown-div-row-wrapper"><div>` +
                `<div class="my-team-user">Krishna Murthy</div>` +
                `</div><div class='my-team-inquiry-box-wrapper my-team-user'><div class='my-team-inquiry-box'>54312</div>
<div class='my-team-inquiry-box'>34214</div>
<div class='my-team-inquiry-box'>12236</div>
<div class='my-team-inquiry-box'>54212</div></div></div></td></tr>`);
            addElement.insertAfter(current);
        }
    });
}

    export default myteamDropdown;