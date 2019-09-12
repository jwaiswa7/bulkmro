import inquiriesNew from "./new";
import inquiriesEdit from "./edit";
import inquiriesEditSuppliers from "./editSuppliers";
import inquiriesUpdateSuppliers from "./updateSuppliers";
import inquiriesAddSuppliers from "./addSuppliers";
import inquiriesIndex from "./index";
import inquiriesKraReport from "./kraReport";
import inquiriesTatReport from "./tatReport";
import pipelineReport from "./pipelineReport";


let inquiries = {
    new: inquiriesNew,
    edit: inquiriesEdit,
    addSuppliers: inquiriesAddSuppliers,
    editSuppliers: inquiriesEditSuppliers,
    updateSuppliers: inquiriesUpdateSuppliers,
    index: inquiriesIndex,
    kraReport: inquiriesKraReport,
    tatReport: inquiriesTatReport,
    pipelineReport: pipelineReport
}

export default inquiries