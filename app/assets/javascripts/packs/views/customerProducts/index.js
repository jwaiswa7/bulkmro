import lazyLoadImages from "../../components/lazyLoadImages";

const index = () => {
    $('.filter-list-input').bindWithDelay('keyup', (e) => {
        searchSubmit(e.target.value)
    }, 500);
};

const searchSubmit = (val) => {
    $.ajax({
        url: self.location.href.split('?')[0],
        data: {q: val},

        beforeSend: function () {
            $("#product-grid").addClass("blur");
        },

        success: function (data) {
            let grid = $("#product-grid", data).html();
            $("#product-grid").html(grid);
            lazyLoadImages();
        },

        complete: function () {
            $("#product-grid").removeClass("blur");
        }
    });
};

export default index