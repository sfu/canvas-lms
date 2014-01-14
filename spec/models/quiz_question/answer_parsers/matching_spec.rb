require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper.rb')
require File.expand_path(File.dirname(__FILE__) + '/answer_parser_spec_helper.rb')

describe QuizQuestion::AnswerParsers::Matching do
  context "#parse" do
    let(:raw_answers) do
      [
        {
          answer_text: "Answer 1",
          answer_match_left: "Answer 1",
          answer_match_right: "Match to Answer 1",
          answer_comment: "This is answer 1",
          answer_weight: 0,
          text_after_answers: "Text after Answer 1"
        },
        {
          answer_text: "Answer 2",
          answer_match_left: "Answer 2",
          answer_match_right: "Match to Answer 2",
          answer_comment: "This is answer 2",
          answer_weight: 100,
          text_after_answers: "Text after Answer 2"
        },
        {
          answer_text: "Answer 3",
          answer_match_left: "Answer 3",
          answer_match_right: "Match to Answer 3",
          answer_comment: "This is answer 3",
          answer_weight: 0,
          text_after_answers: "Text after Answer 3"
        }
      ]
    end

    let(:question_params) do
      {
        matching_answer_incorrect_matches: "",
        question_type: "matching_question"
      }
    end

    let(:parser_class) { QuizQuestion::AnswerParsers::Matching }

    it_should_behave_like "All answer parsers"

  end
end
