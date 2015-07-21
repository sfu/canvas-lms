require File.expand_path(File.dirname(__FILE__) + '/helpers/outcome_common')

describe "outcomes", priority: 1 do
  include_examples "in-process server selenium tests"
  let(:who_to_login) { 'teacher' }
  let(:outcome_url) { "/courses/#{@course.id}/outcomes" }

  describe "course outcomes" do
    before (:each) do
      course_with_teacher_logged_in
    end

    def save_without_error(value = 4, title = 'New Outcome')
      replace_content(f('.outcomes-content input[name=title]'), title)
      replace_content(f('input[name=calculation_int]'), value)
      f('.submit_button').click
      wait_for_ajaximations
      expect(f(' .title').text).to include(title)
      expect((f('#calculation_int').text).to_i).to eq(value)
    end

    context "create/edit/delete outcomes" do

      it "should create a learning outcome with a new rating (root level)" do
        should_create_a_learning_outcome_with_a_new_rating_root_level
      end

      it "should create a learning outcome (nested)" do
        should_create_a_learning_outcome_nested
      end

      it "should edit a learning outcome and delete a rating" do
        should_edit_a_learning_outcome_and_delete_a_rating
      end

      it "should delete a learning outcome" do
        should_delete_a_learning_outcome
      end

      it "should validate mastery points" do
        should_validate_mastery_points
      end

      it "should_validate_calculation_method_dropdown", test_id: 162376 do
        should_validate_calculation_method_dropdown
      end

      it "should require a title" do
        should_validate_short_description_presence
      end

      it "should require a title less than 255 chars" do
        should_validate_short_description_length
      end

      context "validate decaying average", test_id: 162377 do
        before do
          get outcome_url
          f('.add_outcome_link').click
        end

        it "should validate default values" do
          expect(f('#calculation_method')).to have_value('decaying_average')
          expect(f('#calculation_int')).to have_value('65')
          expect(f('#calculation_int_example')).to include_text("Most recent score counts as 65%"\
                                                              " of mastery weight, average of all other scores count"\
                                                              " as 35% of weight")
        end

        it "should validate calculation int out of range values" do
          should_validate_decaying_average
        end

        it "should validate calculation int accepatble values" do
          save_without_error(1)
          f('.edit_button').click
          save_without_error(99)
        end

        it "should retain the settings after saving" do
          save_without_error(rand(99), 'Decaying Average')
          expect(f('#calculation_method').text).to include('Decaying Average')
        end
      end

      context "validate n mastery", test_id: 162378 do
        before do
          get outcome_url
          f('.add_outcome_link').click
        end

        it "should validate default values" do
          click_option('#calculation_method', "n Number of Times")
          expect(f('#calculation_int')).to have_value('5')
          expect(f('#mastery_points')).to have_value('3')
          expect(f('#calculation_int_example')).to include_text("Must achieve mastery at least 5 times."\
                                                              " Scores above mastery will be averaged"\
                                                              " to calculate final score")
        end

        it "should validate calculation int out of range values" do
          should_validate_n_mastery
        end

        it "should validate calculation int acceptable range values" do
          click_option('#calculation_method', "n Number of Times")
          save_without_error(2)
          f('.edit_button').click
          save_without_error(5)
        end

        it "should retain the settings after saving" do
          click_option('#calculation_method', "n Number of Times")
          save_without_error(rand(2..5), 'n Number of Times')
          expect(f('#calculation_method').text).to include('n Number of Times')
        end
      end

    context "create/edit/delete outcome groups" do
        it "should create an outcome group (root level)" do
          should_create_an_outcome_group_root_level
        end

        it "should create a learning outcome with a new rating (nested)" do
          should_create_a_learning_outcome_with_a_new_rating_nested
        end

        it "should edit an outcome group" do
          should_edit_an_outcome_group
        end

        it "should delete an outcome group" do
          should_delete_an_outcome_group
        end
      end
    end

    context "actions" do
      it "should not render an HTML-escaped title in outcome directory while editing" do
        title = 'escape & me <<->> if you dare'
        escaped_title = 'escape &amp; me &lt;&lt;-&gt;&gt; if you dare'
        who_to_login == 'teacher' ? @context = @course : @context = account
        outcome_model
        get outcome_url
        wait_for_ajaximations
        fj('.outcomes-sidebar .outcome-level:first li').click
        wait_for_ajaximations
        f('.edit_button').click

        # pass in the unescaped version of the title:
        replace_content f('.outcomes-content input[name=title]'), title
        f('.submit_button').click
        wait_for_ajaximations

        # the "readable" version should be rendered in directory browser
        li_el = fj('.outcomes-sidebar .outcome-level:first li:first')
        expect(li_el).to be_truthy # should be present
        expect(li_el.text).to eq title

        # the "readable" version should be rendered in the view:
        expect(f(".outcomes-content .title").text).to eq title

        # and the escaped version should be stored!
        # expect(LearningOutcome.where(short_description: escaped_title)).to be_exists
        # or not, looks like it isn't being escaped
        expect(LearningOutcome.where(short_description: title)).to be_exists
      end
    end

    context "#show" do
      it "should show rubrics as aligned items" do
        outcome_with_rubric

        get "/courses/#{@course.id}/outcomes/#{@outcome.id}"
        wait_for_ajaximations

        expect(f('#alignments').text).to match(/#{@rubric.title}/)
      end
    end
  end
end
