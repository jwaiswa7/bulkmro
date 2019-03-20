import inquiriesNew from "./new";
import inquiriesEdit from "./edit";
import inquiriesEditSuppliers from "./editSuppliers";
import inquiriesUpdateSuppliers from "./updateSuppliers";
import inquiriesIndex from "./index";

let inquiries = {
    new: inquiriesNew,
    edit: inquiriesEdit,
    editSuppliers: inquiriesEditSuppliers,
    updateSuppliers: inquiriesUpdateSuppliers,
    index: inquiriesIndex
};

export default inquiries