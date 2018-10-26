const stickyBits = () => {
    $(document).ready(function () {
        $('[data-toggle="sticky"]').css('z-index', 10).stickybits({
            stickyBitStickyOffset: $('.navbar.navbar-expand-lg').height() + 10
        });
    }, false);
};

export default stickyBits