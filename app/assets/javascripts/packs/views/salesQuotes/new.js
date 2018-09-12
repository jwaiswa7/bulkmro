// Imports
import updateMarginAndSellingPrice from "./updateMarginAndSellingPrice";
import updateUnitCostPriceOnSelect from "./updateUnitCostPriceOnSelect";

const newAction = () => {
    updateMarginAndSellingPrice();
    updateUnitCostPriceOnSelect();
};

export default newAction