// Minimal main script placeholder
(function($){
  $(function(){
    // Smooth scroll for in-page anchors
    $(document).on('click', 'a[href^="#"]', function(e){
      var target = document.querySelector(this.getAttribute('href'));
      if(target){ e.preventDefault(); target.scrollIntoView({behavior: 'smooth'}); }
    });
  });
})(jQuery);
