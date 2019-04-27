import inquiriesNew from "./new";
import inquiriesEdit from "./edit";
import inquiriesEditSuppliers from "./editSuppliers";
import inquiriesUpdateSuppliers from "./updateSuppliers";
import inquiriesIndex from "./index";
import inquiriesKraReport from "./kraReport";
import inquiriesCompanyReport from "./companyReport";
let inquiries = {
    new: inquiriesNew,
    edit: inquiriesEdit,
    editSuppliers: inquiriesEditSuppliers,
    updateSuppliers: inquiriesUpdateSuppliers,
    index: inquiriesIndex,
    kraReport: inquiriesKraReport,
    // companyReport: inquiriesCompanyReport
}

export default inquiries