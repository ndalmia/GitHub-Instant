// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require jquery-ui
//= require turbolinks
//= require_tree .

$(document).ready(function () {
  function getQueryParams () {
    function identity (e) { return e; }
    function toKeyValue (params, param) {
      var keyValue = param.split('=');
      var key = keyValue[0], value = keyValue[1];

      params[key] = params[key]?[value].concat(params[key]):value;
      return params;
    }
    return decodeURIComponent(window.location.search).
      replace(/^\?/, '').split('&').
      filter(identity).
      reduce(toKeyValue, {});
  }

  var faye = new Faye.Client("http://10.1.1.225:9292/faye");
  var subscribe_to_channel = function(channel) {
    faye.subscribe(channel, function (data) {
      if(data == "PROCESSED") {
        location.reload();
      }
    });
  }
  
  if(location.pathname == "/") {
   params = getQueryParams();
    var channel = "/"+params.repo.split('/')[3] +"/" +params.repo.split('/')[4];
    subscribe_to_channel(channel);
  }
});