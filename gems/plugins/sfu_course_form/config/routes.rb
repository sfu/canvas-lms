CanvasRails::Application.routes.draw do
  match "/sfu/course/new" => "course_form#new", via: :get
  match "/sfu/course/create" => "course_form#create", via: :post
  match "/sfu/adhoc/new" => "course_form#new_adhoc", via: :get
end
