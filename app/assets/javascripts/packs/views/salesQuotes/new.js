// Imports
import updateMarginAndSellingPrice from "./updateMarginAndSellingPrice";
import updateOnSelect from "./updateOnSelect";
import updateFreightCostAndUnitFreightCost from "./updateFreightCostAndUnitFreightCost"


const newAction = () => {
    updateMarginAndSellingPrice();
    updateOnSelect();
    updateFreightCostAndUnitFreightCost();
};

export default newAction