document.addEventListener('DOMContentLoaded', function () {
  particleground(document.getElementById('particles'), {
    //粒子颜色
    dotColor: '#cbda5a',
    //线颜色
    lineColor: '#eda'
  });
  var intro = document.getElementById('intro');
  intro.style.marginTop = - intro.offsetHeight / 2 + 'px';
}, false);