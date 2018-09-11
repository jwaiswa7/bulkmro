// Resize all texareas (even those dynamically added) when new lines are needed to remove the need for scrolling within a textarea
const textareaAutosize = () => {
    autosize(document.querySelectorAll('textarea'));
};

export default textareaAutosize