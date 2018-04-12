require "rails_helper"

describe Issue do
  labels =  [
              {"id":96390354,"url":"https://api.github.com/repos/bearfact/gitboard/labels/enhancement","name":"enhancement","color":"84b6eb","default":true},
              {"id":101402645,"url":"https://api.github.com/repos/bearfact/gitboard/labels/priority:low","name":"priority:low","color":"ededed","default":false},
              {"id":102038987,"url":"https://api.github.com/repos/bearfact/gitboard/labels/status:passed_qa","name":"status:passed_qa","color":"ededed","default":false}
            ].as_json

  context 'determine status' do
    statuses = [
      IssuesStatus.new(id: 5, repository_id: 2, position: 1, name: "Backlog", label: "", created_at: "2017-04-25 13:43:05", updated_at: "2017-04-25 13:43:05", repositories_id: nil, sprint_id: nil), 
      IssuesStatus.new(id: 6, repository_id: 2, position: 2, name: "In Progress", label: "status:in_progress", created_at: "2017-04-25 13:43:05", updated_at: "2017-04-25 13:43:05", repositories_id: nil, sprint_id: nil), 
      IssuesStatus.new(id: 7, repository_id: 2, position: 3, name: "Ready for QA", label: "status:qa", created_at: "2017-04-25 13:43:05", updated_at: "2017-04-25 13:43:05", repositories_id: nil, sprint_id: nil), 
      IssuesStatus.new(id: 8, repository_id: 2, position: 4, name: "Complete", label: "status:passed_qa", created_at: "2017-04-25 13:43:05", updated_at: "2017-04-25 13:43:05", repositories_id: nil, sprint_id: nil)
    ]

    
    it 'returns a Backlog status when no label exists' do
      expect(Issue.determine_status([], statuses).name).to eq 'Backlog'
    end
    
    it 'returns a Complete status when label complete exists' do
      expect(Issue.determine_status(labels, statuses).name).to eq 'Complete'
    end
  end

  context 'determine_priority' do
    it 'returns a low priority when label low exists' do
      expect(Issue.determine_priority(labels)).to eq 3
    end
  end
 
end