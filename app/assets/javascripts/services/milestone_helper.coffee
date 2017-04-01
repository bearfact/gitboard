f = (Restangular, moment) ->
  'ngInject'
  {
    progressBarType: (milestone) ->
      a = moment(milestone.due_on)
      b = moment(milestone.created_at)
      c = moment()
      totalDays = a.diff(b, 'days')
      daysLeft = a.diff(c, 'days')
      durationPercent = (totalDays - daysLeft) / totalDays
      completedPercent = milestone.closed_issues / (milestone.closed_issues + milestone.open_issues)
      if moment().isAfter(milestone.due_on)
        return 'danger'
      else if durationPercent > completedPercent
        return 'warning'
      'success'
  }

module.exports = f
