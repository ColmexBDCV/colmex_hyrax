$(document).on('.ready(',function(){

    $('textarea[disabled="disabled"]').siblings('span').remove();
    $('textarea[disabled="disabled"]').parent('li').width('100%');
    $('textarea[disabled="disabled"]').parent('li').parent('ul').siblings('button').remove();
    $('textarea[disabled="disabled"]:empty').remove();

});