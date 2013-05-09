$(function(){
  $('.q_count').bind('change', function(){
    var sum = 0;
    $('.q_count').each(function(){
      sum += parseInt(this.value)
    });
$('#sum').text(sum);
      $('#sum').toggleClass("label-success", sum === 100);
  });
});