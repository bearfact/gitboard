require 'ng-toast/dist/ngToast.min.css'
require 'ng-toast/dist/ngToast-animations.css'
require 'sweetalert/lib/sweet-alert.scss'
require 'adm-dtp/dist/ADM-dateTimePicker.min.css'
require 'bootstrap/dist/css/bootstrap.min.css'
require './stylesheets/yeti.bootstrap.min.css'
require './stylesheets/base.scss'



window.jQuery = window.$ = window.jquery = jquery = require 'jquery'
#bootstrap = require 'bootstrap'
Pusher = require 'pusher-js'
angular = require 'angular'
animate = require 'angular-animate'
sanitize = require 'angular-sanitize'
bootstrap = require 'bootstrap/dist/js/bootstrap.min.js'
ngboot = require 'angular-bootstrap'
md = require 'angular-md/dist/angular-md.js'
ngroute = require 'angular-route'
sweet = require 'sweetalert'
ngsweet = require 'angular-sweetalert'
moment = require 'moment'
restangular = require 'restangular'
datepicker = require 'adm-dtp/dist/ADM-dateTimePicker.min.js'
toast = require 'ng-toast'
drag = require 'angular-drag-and-drop-lists'
underscore = require 'underscore'
appconfig = require './javascripts/app.config.coffee'
routes = require './javascripts/routes.coffee'
controllers = require './javascripts/controllers/index.coffee'
directives = require './javascripts/directives/index.coffee'
filters = require './javascripts/filters/index.coffee'
services = require './javascripts/services/index.coffee'

mod = angular.module("gitBoard", ["ngAnimate", "ngSanitize", "ngRoute", "restangular", "ui.bootstrap", "oitozero.ngSweetAlert", "yaru22.md", "ADM-dateTimePicker", "ngToast", "dndLists", controllers, services, filters, directives])
  #.config(appconfig)
  .config(routes)
  .config(['$httpProvider', ($httpProvider) -> $httpProvider.interceptors.push("myHttpInterceptor")])
  .config(['$httpProvider', ($httpProvider) -> $httpProvider.defaults.headers.common["X-CSRF-Token"] = $("meta[name=csrf-token]").attr("content")])
  .config(['RestangularProvider', (RestangularProvider) -> RestangularProvider.setRequestSuffix(".json")])
  .config(['ADMdtpProvider', (ADMdtp) -> ADMdtp.setOptions({calType: 'gregorian',format: 'MM/DD/YYYY', default: 'today', dtpType: 'date'})])
  .config(['ngToastProvider', (ngToastProvider) -> ngToastProvider.configure({animation: 'slide', verticalPosition: 'bottom'})])
  .constant('moment', moment)
  .constant('_', underscore)
  .constant("version", "0.1")
  .constant("token", $("meta[name=csrf-token]").attr("content"))


angular.element(document).ready ->
  jQuery.ajax
    url: '/app_bootstrap'
    contentType: 'application/json'
    dataType: 'json'
    success: (result) ->
      window.current_user = result['current_user']
      app = angular.bootstrap(document, [ 'gitBoard' ])
      ss = app.get('stateService')
      ss.setCurrentUser result['current_user']
      ss.setIssuesStatuses result['statuses']
      return


if(module.hot)
  module.hot.accept()


module.exports = mod
