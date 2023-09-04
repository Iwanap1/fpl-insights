// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"
import "chartkick"
import "Chart.bundle"


$(document).on('turbolinks:load', function(event) {
  var chart = Chartkick.charts['league-points'].getChartObject();
  setInterval(function(){
    var indexToUpdate = Math.round(Math.random() * 30);
    chart.data.datasets[0].data[indexToUpdate] = Math.random() * 100;
    chart.update();
  }, 1);
});
