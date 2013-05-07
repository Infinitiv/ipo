json.array!(@answers) do |answer|
  json.extract! answer, :question_id, :text, :right
  json.url answer_url(answer, format: :json)
end