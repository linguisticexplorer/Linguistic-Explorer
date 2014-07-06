(function(){
  
  // On DOM ready
  $(function() {
    // shorthand
    window.T = Terraling;
  
    // cache the body element
    var body = $('body');

    // Fire the associated js module here
    T.controller = body.data('controller');
    T.action     = body.data('action');
    
    // don't worry about null values for the moment
    T.currentGroup = body.data('group');

    // Load utility code here
    T.Util.init();
      
    // there's an available Terraling module with this name, create it
    if(T[T.controller]){

      if(T[T.controller][T.action]){
        // This is a page specific code
        T[T.controller][T.action].init();

      } else if (T[T.controller].init){
        // This is some code shared within the controller
        T[T.controller].init();

      }

    }

  });

})();
