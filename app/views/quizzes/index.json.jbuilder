json.array!(@quizzes) do |quiz|
  json.extract! quiz, :name, :data
  json.url quiz_url(quiz, format: :json)
end