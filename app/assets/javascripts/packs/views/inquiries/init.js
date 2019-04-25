import inquiriesNew from "./new";
import inquiriesEdit from "./edit";
import inquiriesEditSuppliers from "./editSuppliers";
import inquiriesUpdateSuppliers from "./updateSuppliers";
import inquiriesIndex from "./index";
import inquiriesKraReport from "./kraReport";
import inquiriesTatReport from "./tatReport";


let inquiries = {
    new: inquiriesNew,
    edit: inquiriesEdit,
    editSuppliers: inquiriesEditSuppliers,
    updateSuppliers: inquiriesUpdateSuppliers,
    index: inquiriesIndex,
    kraReport: inquiriesKraReport,
    tatReport: inquiriesTatReport

}

export default inquiries