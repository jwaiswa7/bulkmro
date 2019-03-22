import productsEdit from "./edit";
import productsNew from "./new";
import productsShow from "./show";
import productsIndex from "./index"

let products = {
    show: productsShow,
    edit: productsEdit,
    new: productsNew,
    index: productsIndex
};

export default products