const newAction = () => {
    $('.star').raty({scoreName: 'score',targetType: 'score',click:function(score) {$('#star').val(score);}});
    $('.rating-modal a').click();
};

export default newAction