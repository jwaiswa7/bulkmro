const stickyBits = () => {
    $(document).ready(function () {
        $('[data-toggle="sticky"]').css('z-index', 1).stickybits({
            stickyBitStickyOffset: $('.navbar.navbar-expand-lg').height()
        });
    }, false);
};

export default stickyBits