// Imports
import updateMarginAndSellingPrice from "./updateMarginAndSellingPrice";
import updateOnSelect from "./updateOnSelect";

const newAction = () => {
    updateMarginAndSellingPrice();
    updateOnSelect();
};

export default newAction