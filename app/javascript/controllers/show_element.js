$(document).on('click', '[data-show-element]', function(e) {
  var selector = $(this).attr('data-show-element');
  $(selector).slideDown();
  $(this).hide();
  e.preventDefault();
  return false;
});

$(document).on('click', '[data-hide-element]', function(e) {
  var selector = $(this).attr('data-hide-element');
  $(selector).hide();
  var undo_selector = $("a[data-show-element='" + selector + "']");
  $(undo_selector).show();
  e.preventDefault();
  return false;
});
