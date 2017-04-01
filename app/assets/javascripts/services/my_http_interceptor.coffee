f = ($q, $location, ngToast) ->
  'ngInject'
  {
    response: (response) ->
      data = undefined
      if response.headers()['content-type'] == 'application/json; charset=utf-8'
        data = true
        if !data
          return $q.reject(response)
      response
    responseError: (response) ->
      if response.status == 403
        if response.headers()['content-type'].indexOf('application/json') > -1
          ngToast.danger content: 'Your session has expired.  Please log in again.'
        else
          window.location = '/'
      $q.reject response

  }

module.exports = f
