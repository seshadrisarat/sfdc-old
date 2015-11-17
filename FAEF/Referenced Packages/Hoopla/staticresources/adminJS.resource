
(function () {

    $('#admin-sidebar li.players').click(function(evt){
        $('.admin-flyout').hide();
        $('#users-flyout').show();
        evt.preventDefault();
        return false;
    });

    $('#admin-sidebar li.tv_configs').click(function(evt){
        $('.admin-flyout').hide();
        $('#tv-flyout').show();
        evt.preventDefault();
        return false;
    });

    $('#admin-sidebar li.metrics').click(function(evt){
        $('.admin-flyout').hide();
        $('#metrics-flyout').show();
        evt.preventDefault();
        return false;
    });

    $('#admin-sidebar li.games').click(function(evt){
        $('.admin-flyout').hide();
        $('#game-flyout').show();
        evt.preventDefault();
        return false;
    });

    $('body').click(function(){
        $('.admin-flyout').hide();
    });


}());

