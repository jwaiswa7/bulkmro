const stickTableHead = () => {

    var header = document.getElementById("sticky-nav");
    var sticky = header.offsetTop;
    var nav_bottom = $('#nav-sticky').height()
    var stickPos = nav_bottom + 3;

    window.onscroll = function () {
        if ((document.getElementById('nav-sticky').offsetTop) > sticky) {
            $('#stick-tid').css({'display':'block','top':stickPos});
        } else {
            $('#stick-tid').css('display','none');
        }

    };

}

export default stickTableHead